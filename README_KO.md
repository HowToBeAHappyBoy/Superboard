[English](README.md) | 한국어 | [日本語](README_JA.md)

<img src="assets/icon.png" alt="Superboard icon" width="72" />

# Superboard

Superboard는 macOS 메뉴바에서 동작하는, 키보드 중심의 빠른 붙여넣기 경험에 초점을 둔 클립보드 히스토리 앱입니다.

무언가를 복사한 뒤 Cmd+Shift+V를 누르면 최근 항목 픽커가 뜨고, 항목을 선택하면 현재 포커스된 앱에 바로 붙여넣습니다.

현재는 초기 버전이며 macOS 우선으로 만들고 있습니다. 텍스트, 이미지, 파일 복사를 지원하고, 키보드만으로 빠르게 선택해서 붙여넣는 경험을 목표로 합니다.

## 요구사항

- macOS 14+

## 설치

GitHub Releases에서 최신 `.dmg`(또는 `.zip`)를 다운로드해 설치합니다: https://github.com/HowToBeAHappyBoy/Superboard/releases

macOS가 최초 실행을 막는 경우, Finder에서 앱을 우클릭 → 열기, 또는 시스템 설정 → 개인정보 보호 및 보안에서 허용해 주세요.

## 기능

### 핵심

- 텍스트, 이미지, 파일 히스토리
- 전역 단축키(기본: Cmd+Shift+V)로 픽커 열기
- 키보드 네비게이션과 즉시 붙여넣기

### 설정

- 표시 개수와 저장 개수
- 단축키와 시작 시 자동실행
- 가상 클립보드(붙여넣기 후 원래 클립보드 복원)

## 사용법

1. Superboard를 실행합니다.
2. 텍스트/이미지/파일을 복사합니다.
3. Cmd+Shift+V로 픽커를 엽니다.
4. 항목을 선택하면 현재 포커스된 앱에 바로 붙여넣습니다.

## 스크린샷

아직 준비 중입니다.

## 권한

Superboard는 현재 포커스된 앱에 붙여넣기 위해 Accessibility 권한을 사용합니다.

붙여넣기가 동작하지 않으면 아래를 확인해 보세요:

- 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Superboard 활성화

## 데이터 & 개인정보

Superboard는 로컬에서 동작합니다.

- 클립보드 히스토리는 `~/Library/Application Support/Superboard/history.json`에 저장됩니다.
- 설정은 `UserDefaults`에 저장됩니다.

## 개발

메인테이너용 빌드 스크립트:

```sh
scripts/build-zip.sh
scripts/build-dmg-pretty.sh
```

## 문제 해결

- 픽커는 뜨는데 붙여넣기가 안 됨: Accessibility 권한을 다시 확인하고 앱을 재실행해 보세요.
- 단축키가 동작하지 않음: Superboard 실행 상태를 확인하고, 설정에서 단축키를 변경해 보세요.

## 라이선스

MIT
