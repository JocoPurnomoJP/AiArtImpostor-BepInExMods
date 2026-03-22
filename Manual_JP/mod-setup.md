# Mod 適用手順書

## セットアップ手順

1. [リリースページ](../../../releases/latest) から `SetupScripts.zip` をダウンロードする
2. zip を解凍し、`init.bat` と `update_all_plugins.bat` を取り出す
3. `AIArtImpostor.exe` と同じフォルダに配置する
4. `init.bat` を実行する

実行が完了すると、Mod の動作に必要なファイルが自動的にインストールされます。

### インストールされるファイル

| ファイル | 配置先 |
|---|---|
| BepInEx フレームワーク一式 | ゲームフォルダ直下 |
| ModApplyToggle.dll | ゲームフォルダ\BepInEx\plugins\ |

---

## Mod 適用の確認

ゲームを起動し、画面左上に **「Mod Apply」** と表示されていれば成功です。

> 初回起動は完了まで時間がかかります。しばらく待ってください。

---

## 追加機能の導入

追加機能を導入するには `update_all_plugins.bat` を実行してください。

> セットアップ手順で `SetupScripts.zip` を解凍済みの場合、`update_all_plugins.bat` はすでに手元にあります。

1. `update_all_plugins.bat` を `AIArtImpostor.exe` と同じフォルダに配置する
2. `update_all_plugins.bat` を実行する

利用したい機能の説明書を参照してください。

| 機能 | 手順書 |
|---|---|
| お題一覧表示 | [説明書](mod-show-theme-list.md) |
| カスタムお題 CSV 入力 | [説明書](mod-custom-theme.md) |
| 配信者モード・WordWolf モード | [説明書](mod-conceal-role.md) |

---

## エラーが発生した場合

`init.bat` の実行でエラーが発生した場合は、リポジトリの `init/` フォルダから必要なファイルを手動でダウンロードし、ゲームフォルダに配置してください。
