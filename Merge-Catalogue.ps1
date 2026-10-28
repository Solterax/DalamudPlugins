function Merge-PluginCatalogue {
    param([object[]]$Current = @(), [object[]]$Incoming = @())
    $entries = [ordered]@{}
    foreach ($batch in @(@{ Items = $Current }, @{ Items = $Incoming })) {
        $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($entry in $batch.Items) {
            if ($null -eq $entry -or $entry.InternalName -notmatch '^[A-Za-z0-9_\-]+$') {
                throw 'Every plugin must have a valid InternalName.'
            }
            if (-not $seen.Add($entry.InternalName)) { throw "Duplicate plugin: $($entry.InternalName)" }
            if ([string]::IsNullOrWhiteSpace($entry.Name) -or [string]::IsNullOrWhiteSpace($entry.Author)) {
                throw "Plugin $($entry.InternalName) has no name or author."
            }
            $parsedVersion = $null
            if (-not [version]::TryParse([string]$entry.AssemblyVersion, [ref]$parsedVersion)) {
                throw "Invalid version for $($entry.InternalName)."
            }
            foreach ($field in @('DownloadLinkInstall', 'DownloadLinkUpdate')) {
                $uri = $null
                if (-not [uri]::TryCreate([string]$entry.$field, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
                    throw "Plugin $($entry.InternalName) needs an HTTPS $field."
                }
            }
            $entries[$entry.InternalName] = $entry
        }
    }
    $entries.Values | Sort-Object InternalName
}
