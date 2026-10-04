$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$signingRoot = Join-Path $env:LOCALAPPDATA "CatCafeGame\signing"
$keystorePath = Join-Path $signingRoot "catcafe-upload.p12"
$passwordPath = Join-Path $signingRoot "upload-password.dpapi"
$javaHome = Join-Path $env:LOCALAPPDATA "Programs\Eclipse Adoptium\jdk-17"
$androidHome = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$godotPath = Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_console.exe"
if (-not (Test-Path -LiteralPath $godotPath)) {
	$godotPath = Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_win64_console.exe"
}
$outputDirectory = Join-Path (Split-Path -Parent $projectRoot) "CatCafeGame-builds"
$outputPath = Join-Path $outputDirectory "cat-cafe-1.0.0.aab"
$previousEnvironment = @{
	JAVA_HOME = $env:JAVA_HOME
	ANDROID_HOME = $env:ANDROID_HOME
	ANDROID_SDK_ROOT = $env:ANDROID_SDK_ROOT
	Path = $env:Path
	GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH
	GODOT_ANDROID_KEYSTORE_RELEASE_USER = $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER
	GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
}

foreach ($requiredPath in @($keystorePath, $passwordPath, $javaHome, $androidHome, $godotPath)) {
	if (-not (Test-Path -LiteralPath $requiredPath)) {
		throw "Required Android release file or tool is missing: $requiredPath"
	}
}

$androidBuild = Join-Path $projectRoot "android\build"
$gradleConfigPath = Join-Path $androidBuild "config.gradle"
$gradleWrapperPath = Join-Path $androidBuild "gradle\wrapper\gradle-wrapper.properties"
$gradlePropertiesPath = Join-Path $androidBuild "gradle.properties"
if (-not (Test-Path -LiteralPath $gradleConfigPath)) {
	& $godotPath --headless --editor --path $projectRoot --install-android-build-template --quit
	if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $gradleConfigPath)) {
		throw "Could not install Godot's Android Gradle build template. Install Godot export templates and try again."
	}
}

$gradleConfig = [System.IO.File]::ReadAllText($gradleConfigPath)
$gradleConfig = [regex]::Replace(
	$gradleConfig,
	"(?m)^(\s*androidGradlePlugin:\s*)'[^']+'",
	'${1}''8.13.2'''
)
if ($gradleConfig -notmatch "(?m)^\s*androidGradlePlugin:\s*'8\.13\.2'") {
	throw "Could not configure the Android Gradle Plugin for Android API 36."
}
[System.IO.File]::WriteAllText($gradleConfigPath, $gradleConfig, [System.Text.UTF8Encoding]::new($false))

$gradleWrapper = [System.IO.File]::ReadAllText($gradleWrapperPath)
$gradleWrapper = [regex]::Replace(
	$gradleWrapper,
	"(?m)^distributionUrl=.*$",
	'distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip'
)
if ($gradleWrapper -notmatch '(?m)^distributionUrl=.*gradle-8\.13-bin\.zip$') {
	throw "Could not configure the Gradle wrapper for Android API 36."
}
[System.IO.File]::WriteAllText($gradleWrapperPath, $gradleWrapper, [System.Text.UTF8Encoding]::new($false))

$gradleProperties = [System.IO.File]::ReadAllText($gradlePropertiesPath)
if ($gradleProperties -notmatch '(?m)^org\.gradle\.daemon=false$') {
	$gradleProperties = $gradleProperties.TrimEnd() + "`norg.gradle.daemon=false`n"
	[System.IO.File]::WriteAllText($gradlePropertiesPath, $gradleProperties, [System.Text.UTF8Encoding]::new($false))
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$securePassword = ConvertTo-SecureString ([System.IO.File]::ReadAllText($passwordPath))
$passwordPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)

try {
	$env:JAVA_HOME = $javaHome
	$env:ANDROID_HOME = $androidHome
	$env:ANDROID_SDK_ROOT = $androidHome
	$env:Path = "$javaHome\bin;$androidHome\platform-tools;$env:Path"
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $keystorePath
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = "catcafe-upload"
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)

	& $godotPath --headless --path $projectRoot --export-release "Android AAB" $outputPath
	if ($LASTEXITCODE -ne 0) {
		throw "Godot release export failed with exit code $LASTEXITCODE."
	}

	Get-Item -LiteralPath $outputPath | Select-Object FullName, Length, LastWriteTime
}
finally {
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $previousEnvironment.GODOT_ANDROID_KEYSTORE_RELEASE_PATH
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $previousEnvironment.GODOT_ANDROID_KEYSTORE_RELEASE_USER
	$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $previousEnvironment.GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
	$env:JAVA_HOME = $previousEnvironment.JAVA_HOME
	$env:ANDROID_HOME = $previousEnvironment.ANDROID_HOME
	$env:ANDROID_SDK_ROOT = $previousEnvironment.ANDROID_SDK_ROOT
	$env:Path = $previousEnvironment.Path
	[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
}
