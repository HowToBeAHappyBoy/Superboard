SuperboardはmacOSのメニューバーで動くクリップボード履歴アプリです。

何かをコピーしてからCommand Shift Vを押すとピッカーが開き、項目を選ぶと現在フォーカスされているアプリに貼り付けます。

まだ初期段階で、まずはmacOS向けに作っています。テキスト、画像、ファイルのコピーを扱い、キーボードだけで素早く選んで貼り付けることを目標にしています。

ビルドと実行

一般的なmacOSの開発環境ではSwiftPMで実行できます。

swift test
swift run SuperboardMacApp

SwiftPMが壊れている環境向けに、xcrun swiftcベースのスクリプトも入っています。

scripts/dev-run.sh

パッケージング

scripts/build-zip.shはdist/Superboard-macos.zipを作ります。
scripts/build-dmg-pretty.shはdist/Superboard.dmgを作ります。

権限

Superboardは、フォーカス中のアプリに貼り付けるためにAccessibility権限を使います。
