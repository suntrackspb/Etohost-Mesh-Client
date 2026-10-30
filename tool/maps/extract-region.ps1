# Run on the Windows map workstation. The entire planet is not downloaded.
param(
    [string]$Pmtiles = 'C:\MapWorkshop\tools\pmtiles.exe',
    [string]$SourceUrl = 'https://build.protomaps.com/20261029.pmtiles',
    [string]$Output = 'C:\MapWorkshop\regions\spb-100km.pmtiles',
    [string]$Bbox = '28.49,59.03,32.14,60.84',
    [int]$MaxZoom = 15
)
$ErrorActionPreference = 'Stop'
if (Test-Path $Output) { throw "Output already exists: $Output" }
New-Item -ItemType Directory -Force (Split-Path $Output) | Out-Null
& $Pmtiles extract $SourceUrl $Output "--bbox=$Bbox" "--maxzoom=$MaxZoom" --download-threads=4
if ($LASTEXITCODE -ne 0) { throw 'PMTiles extraction failed' }
& $Pmtiles verify $Output
if ($LASTEXITCODE -ne 0) { throw 'PMTiles verification failed' }
& $Pmtiles show $Output
Get-Item $Output | Select-Object FullName, Length
Get-FileHash $Output -Algorithm SHA256
