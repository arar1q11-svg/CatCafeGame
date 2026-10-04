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

$webPath = Join-Path $projectRoot "web"
$htmlPath = Join-Path $webPath "index.html"
$html = [System.IO.File]::ReadAllText($htmlPath)
$html = $html.Replace('<html lang="en">', '<html lang="ko">')
$seoMetadata = @'
		<meta name="description" content="고양이 카페 키우기: 손님의 주문을 맞히고 나만의 포근한 카페를 운영하는 무료 한국어 세로형 브라우저 게임입니다. 설치 없이 온라인에서 바로 플레이하세요.">
		<meta name="robots" content="index, follow">
		<meta name="theme-color" content="#faf2e8">
		<meta name="google-site-verification" content="WORTVDAzj5LIkGADsc4DDKUwonJToeekLtU7r5mLKHk">
		<link rel="canonical" href="https://arar1q11-svg.github.io/CatCafeGame/">
		<meta property="og:type" content="website">
		<meta property="og:locale" content="ko_KR">
		<meta property="og:site_name" content="고양이 카페 키우기">
		<meta property="og:title" content="고양이 카페 키우기 - 무료 온라인 고양이 카페 게임">
		<meta property="og:description" content="고양이 손님의 주문을 맞히며 나만의 포근한 카페를 운영해 보세요. 설치 없이 무료로 플레이할 수 있습니다.">
		<meta property="og:url" content="https://arar1q11-svg.github.io/CatCafeGame/">
		<meta property="og:image" content="https://arar1q11-svg.github.io/CatCafeGame/index.png">
		<meta name="twitter:card" content="summary_large_image">
		<script type="application/ld+json">
		{
		  "@context": "https://schema.org",
		  "@type": "VideoGame",
		  "name": "고양이 카페 키우기",
		  "description": "고양이 손님의 주문을 맞히고 나만의 포근한 카페를 운영하는 무료 한국어 브라우저 게임입니다.",
		  "url": "https://arar1q11-svg.github.io/CatCafeGame/",
		  "image": "https://arar1q11-svg.github.io/CatCafeGame/index.png",
		  "inLanguage": "ko",
		  "genre": ["Casual", "Simulation"],
		  "gamePlatform": "Web browser",
		  "applicationCategory": "Game",
		  "offers": {
		    "@type": "Offer",
		    "price": "0",
		    "priceCurrency": "KRW"
		  }
		}
		</script>
'@
$titlePattern = '(?m)^\s*<title>.*?</title>\s*$'
if (-not [regex]::IsMatch($html, $titlePattern)) {
	throw "Could not find the exported HTML title to add search metadata."
}
$html = [regex]::Replace(
	$html,
	$titlePattern,
	"		<title>고양이 카페 키우기 - 무료 온라인 고양이 카페 게임</title>`r`n$seoMetadata",
	[System.Text.RegularExpressions.RegexOptions]::Singleline
)
$fallbackPattern = '(?s)<canvas id="canvas">\s*.*?\s*</canvas>'
$fallbackContent = @'
<canvas id="canvas">
			<h1>고양이 카페 키우기 - 무료 온라인 고양이 카페 게임</h1>
			<p>고양이 카페 키우기는 고양이 손님의 주문을 맞히며 카페를 운영하는 무료 한국어 브라우저 게임입니다.</p>
			<p>세로 화면에서 시간 제한 없이 음료와 간식 주문을 처리하고 점수를 모아 최고 기록에 도전해 보세요.</p>
			<p>설치 없이 웹에서 바로 플레이할 수 있으며, 기본 플레이는 오프라인에서도 이용할 수 있습니다.</p>
		</canvas>
'@
if (-not [regex]::IsMatch($html, $fallbackPattern)) {
	throw "Could not find the exported game canvas to add its accessible description."
}
$html = [regex]::Replace($html, $fallbackPattern, $fallbackContent, 1)
[System.IO.File]::WriteAllText($htmlPath, $html, [System.Text.UTF8Encoding]::new($false))

$robotsPath = Join-Path $webPath "robots.txt"
[System.IO.File]::WriteAllText(
	$robotsPath,
	"User-agent: *`r`nAllow: /`r`nSitemap: https://arar1q11-svg.github.io/CatCafeGame/sitemap.xml`r`n",
	[System.Text.UTF8Encoding]::new($false)
)
$sitemapPath = Join-Path $webPath "sitemap.xml"
[System.IO.File]::WriteAllText(
	$sitemapPath,
	"<?xml version=`"1.0`" encoding=`"UTF-8`"?>`r`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`r`n  <url><loc>https://arar1q11-svg.github.io/CatCafeGame/</loc></url>`r`n</urlset>`r`n",
	[System.Text.UTF8Encoding]::new($false)
)

Get-ChildItem -LiteralPath (Join-Path $projectRoot "web") -File |
	Select-Object Name, Length, LastWriteTime
