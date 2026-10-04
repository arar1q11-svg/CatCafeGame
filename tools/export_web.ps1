$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$godotPath = Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_console.exe"
if (-not (Test-Path -LiteralPath $godotPath)) {
	$godotPath = Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_win64_console.exe"
}

if (-not (Test-Path -LiteralPath $godotPath)) {
	throw "Godot was not found at the expected install location."
}

& $godotPath --headless --path $projectRoot --export-release "Web" (Join-Path $projectRoot "web\index.html")
if ($LASTEXITCODE -ne 0) {
	throw "Godot web export failed with exit code $LASTEXITCODE."
}

$requiredFiles = @("index.html", "index.js", "index.wasm", "index.pck")
foreach ($file in $requiredFiles) {
	$path = Join-Path $projectRoot "web\$file"
	if (-not (Test-Path -LiteralPath $path)) {
		throw "The web export is missing a required file: $path"
	}
}

Get-ChildItem -LiteralPath (Join-Path $projectRoot "web") -File |
	Select-Object Name, Length, LastWriteTime
