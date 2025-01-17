# 簡単な音声再生のサンプル

*このサンプルは、Microsoft ゲーム開発キットのプレビュー (2019 年 11 月)
に対応しています。*

# 説明

このサンプルでは、Xbox One で XAudio2 を使用して wav
ファイルを再生する方法を実演します。

![](./media/image1.png)

# サンプルのビルド

Xbox One の devkit を使用している場合は、アクティブなソリューション
プラットフォームを Gaming.Xbox.XboxOne.x64 に設定します。

Project Scarlett を使用している場合は、アクティブなソリューション
プラットフォームを Gaming.Xbox.Scarlett.x64 に設定します。

*詳細については、GDK
ドキュメント*の「サンプルの実行」を*参照してください*。

# サンプルの使用

このサンプルでは、ビュー
ボタンを押して終了する以外の操作はできません。このサンプルでは、各 wav
ファイルの再生が終わると自動的に次のファイルに進みます。

# 実装に関する注意事項

このサンプルでは、PCM、ADPCM、xWMA、XMA2 形式の wav
ファイルの再生方法を実演します。*ATG Tool Kit* の
**WAVFileReader.h/.cpp** ファイルにあるヘルパー
コードを使用します。簡単な wav
ファイルパーサーと、サポートしている形式の音声の再生時間を計算するコードを実装します。

# プライバシーに関する声明

サンプルをコンパイルして実行すると、サンプルの使用状況を追跡するため、サンプル実行可能ファイルのファイル名が
Microsoft に送信されます。このデータ収集を無効にするには、「Sample Usage
Telemetry」とラベル付けされた Main.cpp
内のコードのブロックを削除します。

Microsoft のプライバシー方針の詳細については、「[Microsoft
プライバシーに関する声明](https://privacy.microsoft.com/en-us/privacystatement/)」を参照してください。
