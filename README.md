# Solterax's Dalamud plugins

Add this one URL to Dalamud to browse and install plugins from this catalogue:

```text
https://raw.githubusercontent.com/Solterax/DalamudPlugins/main/pluginmaster.json
```

In game, open `/xlsettings`, go to **Experimental → Custom Plugin Repositories**, add the URL and enable it, then save. Open `/xlplugins` to install plugins or check for updates.

| Plugin | Description | Source and releases |
| --- | --- | --- |
| GearScout | Build gear and glam lists, track owned and missing pieces, and highlight missing loot. | [GearScout](https://github.com/Solterax/GearScout) |
| Magityper | Read enemy prompts and type into a selected game text box. Prototype; in-game mapping and verification required. | [Magityper](https://github.com/Solterax/Magityper) |

If you already use the GearScout-specific feed, replace that URL with the shared URL. GearScout keeps its existing internal name, releases and local configuration. The old feed remains available for existing users.

## Add a plugin

Keep each plugin's source and releases in its own repository. Publish its Dalamud index as a public HTTPS JSON array, including a unique `InternalName`, version and install/update ZIP links. Add that index URL to `sources.json`, update the table above and push. One feed can also contain multiple plugins.

The refresh workflow runs on source-list changes, manual dispatch, and a schedule every 30 minutes (GitHub may delay scheduled runs). It merges entries by `InternalName` and preserves other plugins. Duplicate names across incoming feeds or invalid entries fail the refresh and leave the published catalogue intact. Entries absent from feeds are kept; to retire a plugin, remove its source and remove or hide its entry explicitly.

After publishing a plugin release, refresh immediately with:

```powershell
gh workflow run refresh.yml --repo Solterax/DalamudPlugins
```

Or choose **Actions → Refresh plugin catalogue → Run workflow** on GitHub. A feed must point to an uploaded, published release before refreshing it here.

To check or refresh locally, use PowerShell 7:

```powershell
./Test-Catalogue.ps1
./Refresh-Catalogue.ps1
```

The catalogue contains public plugin metadata and download links. Character settings and inventories stay in each plugin's local configuration.
