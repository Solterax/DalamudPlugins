$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Merge-Catalogue.ps1')
$script:checks = 0
function Assert($condition, $name) {
    if (-not $condition) { throw "FAIL: $name" }
    $script:checks++
}
function Entry($name, $version = '1.0.0.0') {
    [pscustomobject]@{ InternalName = $name; Name = $name; Author = 'Solterax'; AssemblyVersion = $version;
        DownloadLinkInstall = "https://example.com/$name.zip"; DownloadLinkUpdate = "https://example.com/$name.zip" }
}
$a = Entry 'GearScout'
$b = Entry 'AnotherPlugin'
$update = Entry 'GearScout' '2.0.0.0'
$result = @(Merge-PluginCatalogue -Current @($a, $b) -Incoming @($update))
Assert ($result.Count -eq 2) 'Updating one plugin preserves another plugin'
Assert (($result | Where-Object InternalName -eq GearScout).AssemblyVersion -eq '2.0.0.0') 'Updated version replaces old version'
Assert (($result | Where-Object InternalName -eq AnotherPlugin).DownloadLinkInstall -eq $b.DownloadLinkInstall) 'Other download links remain unchanged'
Assert (@(Merge-PluginCatalogue -Current @($a) -Incoming @($b)).Count -eq 2) 'A new plugin is appended'
$roundTrip = ConvertTo-Json -InputObject $result -Depth 32 | ConvertFrom-Json
Assert ($roundTrip.Count -eq 2) 'Multiple entries survive JSON serialization'
foreach ($invalid in @(
    @($a, $a),
    @((Entry 'Invalid name')),
    @((Entry 'InvalidVersion' 'nope')),
    @([pscustomobject]@{ InternalName = 'BadUrl'; Name = 'Bad'; Author = 'Solterax'; AssemblyVersion = '1.0.0'; DownloadLinkInstall = 'http://example.com/a.zip'; DownloadLinkUpdate = 'https://example.com/a.zip' })
)) {
    $rejected = $false
    try { $null = @(Merge-PluginCatalogue -Current @($b) -Incoming $invalid) } catch { $rejected = $true }
    Assert $rejected 'Invalid or duplicate incoming entries are rejected'
}
Assert ($a.AssemblyVersion -eq '1.0.0.0') 'Merge leaves source entries unchanged'
Write-Output "$script:checks catalogue checks passed."
