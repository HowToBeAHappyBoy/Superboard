Superboard는 macOS 메뉴바에서 동작하는 클립보드 히스토리 앱입니다.

무언가를 복사한 뒤 Command Shift V를 누르면 최근 항목 픽커가 뜨고, 항목을 선택하면 현재 포커스된 앱에 바로 붙여넣습니다.

현재는 초기 버전이며 macOS 우선으로 만들고 있습니다. 텍스트, 이미지, 파일 복사를 지원하고, 키보드만으로 빠르게 선택해서 붙여넣는 경험을 목표로 합니다.

빌드와 실행

일반적인 macOS 개발 환경에서는 SwiftPM으로 실행할 수 있습니다.

swift test
swift run SuperboardMacApp

SwiftPM이 깨진 환경을 위해 xcrun swiftc 기반 스크립트도 포함되어 있습니다.

scripts/dev-run.sh

패키징

scripts/build-zip.sh는 dist/Superboard-macos.zip을 만듭니다.
scripts/build-dmg-pretty.sh는 dist/Superboard.dmg를 만듭니다.

권한

Superboard는 현재 포커스된 앱에 붙여넣기 위해 Accessibility 권한을 사용합니다.

