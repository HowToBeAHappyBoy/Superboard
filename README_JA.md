[English](README.md) | [한국어](README_KO.md) | 日本語

<img src="assets/icon.png" alt="Superboard icon" width="72" />

# Superboard

SuperboardはmacOSのメニューバーで動く、キーボード中心の高速ペーストにフォーカスしたクリップボード履歴アプリです。

何かをコピーしてからCmd+Shift+Vを押すとピッカーが開き、項目を選ぶと現在フォーカスされているアプリに貼り付けます。

まだ初期段階で、まずはmacOS向けに作っています。テキスト、画像、ファイルのコピーを扱い、キーボードだけで素早く選んで貼り付けることを目標にしています。

## 動作環境

- macOS 14+

## インストール

GitHub Releasesから最新の`.dmg`(または`.zip`)をダウンロードしてインストールします: https://github.com/HowToBeAHappyBoy/Superboard/releases

macOSが初回起動をブロックする場合は、Finderでアプリを右クリック → 開く、またはシステム設定 → プライバシーとセキュリティで許可してください。

## 機能

### コア

- テキスト、画像、ファイルの履歴
- グローバルショートカット(デフォルト: Cmd+Shift+V)でピッカーを起動
- キーボード操作と即時ペースト

### 設定

- 表示数と保存数
- ショートカットとログイン時起動
- 仮想クリップボード(貼り付け後に元のクリップボードを復元)

## 使い方

1. Superboardを起動します。
2. テキスト/画像/ファイルをコピーします。
3. Cmd+Shift+Vでピッカーを開きます。
4. 項目を選ぶと、現在フォーカスされているアプリに貼り付けます。

## スクリーンショット

まだ準備中です。

## 権限

Superboardは、フォーカス中のアプリに貼り付けるためにAccessibility権限を使います。

貼り付けが動かない場合は、以下を確認してください:

- システム設定 → プライバシーとセキュリティ → アクセシビリティ → Superboardを有効化

## データ & プライバシー

Superboardはローカルで動作します。

- クリップボード履歴は `~/Library/Application Support/Superboard/history.json` に保存されます。
- 設定は `UserDefaults` に保存されます。

## 開発

メンテナ向けビルドスクリプト:

```sh
scripts/build-zip.sh
scripts/build-dmg-pretty.sh
```

## トラブルシューティング

- ピッカーは開くが貼り付けできない: Accessibility権限を再確認し、アプリを再起動してください。
- ショートカットが動かない: Superboardが起動中か確認し、設定でショートカットを変更してみてください。

## ライセンス

MIT
