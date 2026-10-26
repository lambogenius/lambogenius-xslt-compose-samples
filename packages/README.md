# packages

Save the Compose using XSLT package here:

1. Sign in at <https://lambogenius.com/app/downloads/xslt-compose>.
2. Download `Lambogenius.XsltCompose.LogicApps.1.0.0.nupkg`. Its SHA-256 is shown next to the link.
3. Save it in this folder.

The `nuget.config` at the repository root makes this folder a package source, so every sample finds the package
here. Git ignores `.nupkg` files in this folder.

Check the file before you use it (PowerShell):

```powershell
(Get-FileHash packages/Lambogenius.XsltCompose.LogicApps.1.0.0.nupkg -Algorithm SHA256).Hash.ToLower()
```
