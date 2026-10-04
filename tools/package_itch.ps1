$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$exportScript = Join-Path $PSScriptRoot "export_web.ps1"
& $exportScript
if ($LASTEXITCODE -ne 0) {
	throw "The web export failed; the itch.io package was not created."
}

$webPath = Join-Path $projectRoot "web"
$outputDirectory = Join-Path (Split-Path -Parent $projectRoot) "CatCafeGame-builds\itch"
$archivePath = Join-Path $outputDirectory "CatCafeGame-html.zip"

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
if (Test-Path -LiteralPath $archivePath) {
	Remove-Item -LiteralPath $archivePath
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
	$webPath,
	$archivePath,
	[System.IO.Compression.CompressionLevel]::Optimal,
	$false
)

$archive = Get-Item -LiteralPath $archivePath
Write-Output "Created itch.io HTML game package: $($archive.FullName)"
Write-Output "Package size: $([math]::Round($archive.Length / 1MB, 2)) MB"
