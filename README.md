# AiArtImpostor-BepInExMods
This repository is for Unity Game AiArtImpostor PC with Mod.  
I confirmed Mods can work in Windows 11 with AiArtImpostor "ver 0.17.3" .  
This Mod is an unofficial , please observe the following when developing and using this Mod.  

1. Mod development and use is as your own risk. Please deal with any problems by yourself.  
2. Do not contact AiArtImpostor official support. This Mod is unrelated to the official channel.  
3. Secondary distribution is prohibited. Do not transfer or make this Mod in publish downloaded to the others.  

If requested by the original game developers or copyright holders, this Mod will be removed from public distribution without objection.

このRepositryはAiArtImpostorのPC版のModになります。  
Windows11とゲーム本体はver0.17.3でModが動くことを確認しております。  
非公式Modのため、本Modの利用において、以下を遵守してください。  

1. Modの開発および利用は自己責任。発生した問題については自分で対処してください。  
2. AiArtImpostorの公式に問い合わせないこと。本Modと公式は無関係です。  
3. Modの２次配布禁止。Modを他人に譲渡しないで下さい。必ず本サイトから入手してください。  

本Modについて、ゲーム開発元または著作権者からの削除要請があった場合、速やかに公開を停止いたします。

# Modを適用するためには
以下、日本語のみ対応

まず **[Mod 適用手順書](Manual_JP/mod-setup.md)** の手順でセットアップを行ってください。

セットアップ完了後、以下の機能を利用できます。

| 機能 | 概要 | 手順書 |
|---|---|---|
| お題一覧表示 | 試合中に選択されたジャンル・お題の一覧を確認する | [説明書](Manual_JP/mod-show-theme-list.md) |
| カスタムお題 CSV 入力 | CSV ファイルでカスタムお題を入力する（最大100文字） | [説明書](Manual_JP/mod-custom-theme.md) |
| 配信者モード | 役割を画面から秘匿し、配信中に安全にプレイする | [説明書](Manual_JP/mod-conceal-role.md) |
| WordWolf モード | インポスターに異なるお題を配布してゲームを楽しむ | [説明書](Manual_JP/mod-conceal-role.md) |

# 免責 Disclaimer
当 Mod 利用によるトラブルは一切責任を負いません  
The author takes no responsibility for any issues or damages caused by the use of this Mod.

# ライセンスについて
本Modはオープンソースではありません。  
本Modの再配布は禁止されています。  
本Modの著作権その他すべての権利は開発者（Joco Purnomo）に帰属します。  
本Modは非公式のものであり、ゲームの開発元とは一切関係ありません。  

# 本リポジトリの構成
```bash
root
  ├── img                             <--- README向けの画像があるフォルダ
  ├── init                            <--- init.batでダウンロードするメイン対象フォルダ
  ├── Manual_JP                       <--- Modの適用手順書や各Modの説明書がある
  ├── plugins                         
  │   ├── ModApplyToggle.dll          <--- 他のModから参照される基幹Mod※これは環境構築時に自動的に適用されます。これがないと他のModも動きません
  │   ├── ModConcealRole.dll          <--- 配信者向け役割秘匿機能、WordWolfモードで遊ぶ機能を追加する
  │   ├── ModCustomTheme.dll          <--- カスタムお題をCSVファイルを読み込み入力できるボタンを追加する
  │   ├── ModShowThemeList.dll        <--- 試合中に選択されたジャンル・カスタムお題の一覧を確認できる機能を追加する
  │   └── WinFileDialogDllCPlus.dll   <--- ModCustomTheme.dllを使う時に使用するdllファイル
  ├── init.bat                        <--- Mod適用を可能にするための環境構築・インストールBat
  ├── README.md                       <--- README本体ファイル。GitHubのリポジトリはこれを読み込んでWelcomeページとする
  ├── LICENSE.md                      <--- ライセンスについて英文で記述、２次配布禁止などを記載
  └── update_all_plugins.bat          <--- pluginsフォルダにある全ての最新DLLを自動的に取得、Local環境のBepInEx\pluginsに上書き・配置するBat
