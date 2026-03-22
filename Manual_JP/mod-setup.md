# Mod 適用手順書

## 必要なファイルの取得

リポジトリルート直下にある `init.bat` を取得してください。
`AIArtImpostor.exe` があるフォルダに移動させ、その中で実行してください。

実行すると自動的にファイル・フォルダのダウンロードが始まります。

---

## init.bat 実行後のフォルダ構成

実行前と実行後でフォルダ構成が以下のように変わります。

**実行前（ゲームフォルダ直下）**
```
AIArtImpostor.exe
init.bat         ← 配置したもの
```

**実行後（ゲームフォルダ直下）**
```
AIArtImpostor.exe
init.bat
winhttp.dll
doorstop_config.ini
.doorstop_version
BepInEx\
dotnet\
```

---

## 追加 Mod の導入

`BepInEx\plugins\` フォルダに使用したい Mod の DLL ファイルを配置することで、起動時に Mod が適用されます。

各 DLL の取得方法：

1. リポジトリの `plugins/` フォルダを開く
2. 必要な DLL ファイルの個別ページへ移動
3. ダウンロードマークをクリックして取得
4. ゲームフォルダ内の `BepInEx\plugins\` に配置

すべての最新 DLL を一括取得する場合は `update_all_plugins.bat` を使用してください（`init.bat` と同じ方法で取得・実行）。

---

## ModApplyToggle.dll について

`ModApplyToggle.dll` はすべての Mod の基盤となる必須 Mod です。
`init.bat` の実行時に自動的に `BepInEx\plugins\` へ配置されます。
この DLL がない場合、他の Mod も動作しません。

---

## ウィルス対策ソフトの警告について

`winhttp.dll`（BepInEx のフック機構）がウィルス対策ソフトに誤検知される場合があります。
該当ファイルを除外設定に追加するか、一時的に無効にした状態で `init.bat` を実行してください。

---

## 初回起動時の注意

初回起動時は IL2CPP の中間ファイルを生成するため、起動に時間がかかります。
これは正常な動作です。しばらく待ってください。

---

## Mod 適用の確認

ゲームが起動したら、画面左上に **「Mod Apply」** というラベルが表示されていることを確認してください。
このラベルが表示されていれば、Mod は正常に適用されています。

**F8 キー** を押すことで、Mod の UI 表示を切り替えることができます。

---

## init.bat でエラーが発生した場合

力技になりますが、`init/` フォルダの中身を手動でダウンロードして、
所定のフォルダ・ファイル構成を作ることでも Mod の適用は可能です。

1. `init/BepInEx/`、`init/dotnet/`、`init/winhttp.dll`、`init/doorstop_config.ini`、`init/.doorstop_version` を取得
2. ゲームフォルダ直下に配置
3. `plugins/ModApplyToggle.dll` を取得し `BepInEx\plugins\` に配置

ファイルの欠落や破損がある場合も `init/` フォルダから直接ダウンロードして補完してください。

---

## 免責

本 Mod の利用によるトラブルは一切責任を負いません。
本 Mod は非公式であり、ゲーム開発元とは一切関係ありません。
