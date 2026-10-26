<?xml version="1.0" encoding="utf-8"?>
<!--
  Invoice with C# helpers in msxsl:script. The action needs enableScripts=true.

  Script methods take and return string, bool or double, which map to XPath string, boolean and number. Scripts can
  use System, System.Text and System.Text.RegularExpressions (approved namespaces); other framework types are written
  with their full names, as in System.Globalization.CultureInfo below.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:fmt="urn:samples:format"
    xmlns:chk="urn:samples:checks"
    exclude-result-prefixes="msxsl fmt chk">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="currency" select="'CAD'"/>

  <!-- Formatting helpers. -->
  <msxsl:script language="C#" implements-prefix="fmt">
    <![CDATA[
      private static readonly System.Globalization.CultureInfo Invariant = System.Globalization.CultureInfo.InvariantCulture;

      public string Money(double amount, string currency)
      {
          return amount.ToString("#,##0.00", Invariant) + " " + currency;
      }

      // "2026-10-20" -> "20 Oct 2026"
      public string LongDate(string isoDate)
      {
          return DateTime.ParseExact(isoDate.Trim(), "yyyy-MM-dd", Invariant).ToString("dd MMM yyyy", Invariant);
      }

      // "m5x1a9" -> "M5X 1A9"
      public string PostalCode(string value)
      {
          var code = Regex.Replace(value ?? "", "[^A-Za-z0-9]", "").ToUpperInvariant();
          return code.Length == 6 ? code.Substring(0, 3) + " " + code.Substring(3) : code;
      }

      // "gadget, large" -> "Gadget, Large"
      public string TitleCase(string value)
      {
          return Invariant.TextInfo.ToTitleCase((value ?? "").Trim().ToLowerInvariant());
      }
    ]]>
  </msxsl:script>

  <!-- Validation helpers, in their own namespace. -->
  <msxsl:script language="C#" implements-prefix="chk">
    <![CDATA[
      public bool IsValidSku(string sku)
      {
          return Regex.IsMatch((sku ?? "").Trim(), "^[A-Za-z]{3}-[0-9]{2}$");
      }

      // Luhn (mod 10) check digit over the digits of the order number: "ord-1001" -> "ORD-1001-7".
      public string WithCheckDigit(string orderNumber)
      {
          var text = (orderNumber ?? "").Trim().ToUpperInvariant();
          var digits = Regex.Replace(text, "[^0-9]", "");
          int sum = 0;
          bool doubleIt = true;
          for (int i = digits.Length - 1; i >= 0; i--)
          {
              int d = digits[i] - '0';
              if (doubleIt) { d *= 2; if (d > 9) d -= 9; }
              sum += d;
              doubleIt = !doubleIt;
          }
          return text + "-" + ((10 - sum % 10) % 10).ToString();
      }
    ]]>
  </msxsl:script>

  <xsl:template match="/Order">
    <xsl:variable name="amounts">
      <xsl:for-each select="Lines/Line">
        <amount><xsl:value-of select="Quantity * UnitPrice"/></amount>
      </xsl:for-each>
    </xsl:variable>

    <Invoice>
      <Reference><xsl:value-of select="chk:WithCheckDigit(string(Number))"/></Reference>
      <Date><xsl:value-of select="fmt:LongDate(string(OrderDate))"/></Date>
      <ShipTo>
        <Name><xsl:value-of select="ShipTo/Name"/></Name>
        <City><xsl:value-of select="ShipTo/City"/></City>
        <PostalCode><xsl:value-of select="fmt:PostalCode(string(ShipTo/PostalCode))"/></PostalCode>
      </ShipTo>
      <Lines>
        <xsl:for-each select="Lines/Line">
          <Line valid="{chk:IsValidSku(string(Sku))}">
            <Description><xsl:value-of select="fmt:TitleCase(string(Description))"/></Description>
            <Amount><xsl:value-of select="fmt:Money(Quantity * UnitPrice, $currency)"/></Amount>
          </Line>
        </xsl:for-each>
      </Lines>
      <Total><xsl:value-of select="fmt:Money(sum(msxsl:node-set($amounts)/amount), $currency)"/></Total>
    </Invoice>
  </xsl:template>
</xsl:stylesheet>
