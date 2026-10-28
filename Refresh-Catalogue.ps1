param([string]$SourcesPath = (Join-Path $PSScriptRoot 'sources.json'),
      [string]$CataloguePath = (Join-Path $PSScriptRoot 'pluginmaster.json'))
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Merge-Catalogue.ps1')

$sources = @(Get-Content -Raw -LiteralPath $SourcesPath | ConvertFrom-Json)
if ($sources.Count -eq 0) { throw 'Add at least one plugin feed to sources.json.' }
$incoming = @()
foreach ($source in $sources) {
    $uri = $null
    if (-not [uri]::TryCreate([string]$source, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
        throw 'Plugin feed URLs must use HTTPS.'
    }
    $response = Invoke-WebRequest -Uri $source -TimeoutSec 60
    $json = [string]$response.Content
    if (-not $json.TrimStart().StartsWith('[')) { throw "Feed is not a JSON array: $source" }
    $plugins = @($json | ConvertFrom-Json)
    if ($plugins.Count -eq 0) { throw "Plugin feed is empty: $source" }
    $incoming += $plugins
}
$current = if (Test-Path -LiteralPath $CataloguePath) { @(Get-Content -Raw -LiteralPath $CataloguePath | ConvertFrom-Json) } else { @() }
# Download and validate every feed before changing the catalogue. A failure keeps the last good copy.
$merged = @(Merge-PluginCatalogue -Current $current -Incoming $incoming)
$json = ConvertTo-Json -InputObject $merged -Depth 32
[IO.File]::WriteAllText([IO.Path]::GetFullPath($CataloguePath), $json + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "Catalogue contains $($merged.Count) plugin(s)."
