# Superboard

SuperboardはmacOSのメニューバーで動くクリップボード履歴アプリです。

何かをコピーしてからCmd+Shift+Vを押すとピッカーが開き、項目を選ぶと現在フォーカスされているアプリに貼り付けます。

まだ初期段階で、まずはmacOS向けに作っています。テキスト、画像、ファイルのコピーを扱い、キーボードだけで素早く選んで貼り付けることを目標にしています。

## 機能

- テキスト、画像、ファイルの履歴
- グローバルショートカット(デフォルト: Cmd+Shift+V)
- キーボード操作と即時ペースト
- 設定: 表示数、保存数、ショートカット、ログイン時起動、仮想クリップボード

## ビルドと実行

一般的なmacOSの開発環境ではSwiftPMで実行できます。

```sh
swift test
swift run SuperboardMacApp
```

SwiftPMが壊れている環境向けに、`xcrun swiftc`ベースのスクリプトも入っています。

```sh
scripts/dev-run.sh
```

## パッケージング

```sh
scripts/build-zip.sh
scripts/build-dmg-pretty.sh
```

生成物は`dist/`に出力され、gitには含めません。

## 権限

Superboardは、フォーカス中のアプリに貼り付けるためにAccessibility権限を使います。

