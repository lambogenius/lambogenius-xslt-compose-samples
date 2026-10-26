using System.Net;
using System.Text;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Lambogenius.Samples.Functions;

/// <summary>
/// The lookup behind az:InvokeText('GetCustomerName', id). Contract (docs/configuration.md): POST
/// application/json {"value": "..."} -> 200 text/plain; charset=utf-8 with the exact text. 400 for malformed input,
/// 404 for an unknown identifier. Pure lookup, so it is safe to cache within a transformation and to retry.
/// </summary>
public sealed class GetCustomerName
{
    // Synthetic data only.
    private static readonly IReadOnlyDictionary<string, string> Customers = new Dictionary<string, string>(StringComparer.Ordinal)
    {
        ["C100"] = "Acme Supplies",
        ["C200"] = "Globex Retail",
        ["C300"] = "Initech Ltd. – Études",
    };

    private readonly ILogger<GetCustomerName> logger;

    public GetCustomerName(ILogger<GetCustomerName> logger)
    {
        this.logger = logger;
    }

    // AuthorizationLevel.Function: callers send x-functions-key (FunctionKey mode). For managed identity callers,
    // see README.md (App Service authentication with Microsoft Entra ID).
    [Function("GetCustomerName")]
    public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData request)
    {
        string? value;
        try
        {
            using var document = await JsonDocument.ParseAsync(request.Body);
            value = document.RootElement.ValueKind == JsonValueKind.Object
                && document.RootElement.TryGetProperty("value", out var property)
                && property.ValueKind == JsonValueKind.String
                    ? property.GetString()
                    : null;
        }
        catch (JsonException)
        {
            value = null;
        }

        if (value is null)
        {
            return await Text(request, HttpStatusCode.BadRequest, "Expected a JSON object with a string property 'value'.");
        }

        // Log the outcome, not the identifier.
        if (!Customers.TryGetValue(value, out var name))
        {
            logger.LogInformation("Customer lookup: not found.");
            return await Text(request, HttpStatusCode.NotFound, "Unknown customer.");
        }

        logger.LogInformation("Customer lookup: found.");
        return await Text(request, HttpStatusCode.OK, name);
    }

    private static async Task<HttpResponseData> Text(HttpRequestData request, HttpStatusCode status, string text)
    {
        var response = request.CreateResponse(status);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
        await response.Body.WriteAsync(Encoding.UTF8.GetBytes(text));
        return response;
    }
}
