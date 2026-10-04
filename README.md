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

1. GitHub에서 `CatCafeGame` 이름의 **공개 저장소**를 만듭니다.
2. 이 프로젝트의 내용을 저장소에 업로드하고 기본 브랜치에 반영합니다.
3. 저장소의 **Settings → Pages → Build and deployment → Source**에서 **GitHub Actions**를 선택합니다.
4. `.github/workflows/pages.yml`이 웹 게임을 자동으로 게시합니다.
5. 저장소의 **Actions** 탭에서 `Publish web game`이 완료되면 `https://<GitHub-사용자명>.github.io/CatCafeGame/`에서 플레이할 수 있습니다.

GitHub Pages로 게시된 사이트는 인터넷에 공개됩니다. 저장소에는 게임 파일만 올리고, 서명 키나 비밀번호 파일은 절대 올리지 마세요.

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
