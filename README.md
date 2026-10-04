# 고양이 카페 키우기

시간 제한 없이 고양이 손님의 주문을 처리하는 세로 화면 게임입니다. Godot 4.7.2로 만들며, 브라우저에서 바로 플레이할 수 있습니다.

## 웹에서 실행

`web/` 폴더는 Godot에서 내보낸 정적 웹 게임입니다. `index.html`만 파일 탐색기에서 직접 열지 말고, HTTP 서버나 GitHub Pages에서 실행하세요.

웹 파일을 다시 내보내려면 프로젝트 폴더에서 PowerShell을 열고 다음을 실행합니다.

```powershell
.\tools\export_web.ps1
```

로컬 브라우저에서 확인하려면 별도 PowerShell 창에서 다음을 실행한 후 `http://127.0.0.1:8765/`를 여세요.

```powershell
node .\tools\serve_web.js
```

이미 서버를 사용 중이면 끝에 다른 포트를 지정할 수 있습니다. 예: `node .\tools\serve_web.js 8766`.

최고 점수는 브라우저별 기기 저장소에 저장됩니다. 브라우저 데이터를 지우면 기록도 초기화될 수 있습니다.

## GitHub Pages 게시

공개 저장소와 GitHub Actions 배포 설정은 이미 준비되어 있습니다.

- 저장소: <https://github.com/arar1q11-svg/CatCafeGame>
- 웹에서 플레이: <https://arar1q11-svg.github.io/CatCafeGame/>

`web/` 또는 `.github/workflows/pages.yml`을 `main` 브랜치에 반영하면 `Publish web game` workflow가 자동으로 웹 버전을 게시합니다. 배포 진행 상황과 오류는 저장소의 **Actions** 탭에서 확인할 수 있습니다.

GitHub Pages로 게시된 사이트는 인터넷에 공개됩니다. 저장소에는 게임 파일만 올리고, 서명 키나 비밀번호 파일은 절대 올리지 마세요.

### Google 검색에 등록

웹 내보내기에는 한국어 페이지 제목·설명, 게임 구조화 데이터, `robots.txt`, 사이트맵이 포함됩니다. 변경 사항이 게시된 후 [Google Search Console](https://search.google.com/search-console/)에서 URL 접두어 속성 `https://arar1q11-svg.github.io/CatCafeGame/`을 추가하고, 사이트맵 주소 `https://arar1q11-svg.github.io/CatCafeGame/sitemap.xml`을 제출하세요. 사이트 소유권 확인은 Google 계정 소유자가 직접 완료해야 합니다.

Google이 색인을 만들고 `고양이 카페 키우기` 검색 결과에 반영하기까지 며칠 이상 걸릴 수 있으며, 사이트맵 제출만으로 노출 순위나 색인이 보장되지는 않습니다.

### itch.io용 웹 게임 패키지

최신 웹 게임을 itch.io에 올릴 ZIP 파일로 내보내려면 PowerShell에서 다음을 실행하세요.

```powershell
.\tools\package_itch.ps1
```

생성된 `CatCafeGame-html.zip`을 itch.io 프로젝트의 **HTML** 파일로 업로드하고 브라우저 내 실행을 켜면 됩니다.

## Windows에서 개발 및 Android 빌드

- Godot Engine 4.7.2 Standard
- OpenJDK 17
- Android SDK Platform 36과 Build Tools 36.1.0

Godot에서 `project.godot`을 열면 됩니다. Google Play 제출용 서명 AAB는 다음 명령으로 다시 빌드할 수 있습니다. Godot 4.7.2 Android 내보내기 템플릿이 설치되어 있으면 필요한 Gradle 프로젝트를 자동으로 준비합니다.

```powershell
.\tools\export_release.ps1
```

출시 AAB와 비공개 업로드 서명 키는 Git 저장소 밖에 보관합니다.

화면에 사용한 Noto Sans KR 글꼴은 SIL Open Font License 1.1로 배포됩니다. 라이선스 전문은 `assets/fonts/OFL.txt`에 있습니다.
