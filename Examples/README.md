# SampleApp

VoicevoxCoreSwift を使ったサンプルアプリ。

## Requirements

### iOS

native ディレクトリに 2つの xcframework を配置します
- https://github.com/VOICEVOX/voicevox_core/releases/download/0.16.0/voicevox_core-ios-xcframework-cpu-0.16.0.zip
- https://github.com/VOICEVOX/onnxruntime-builder/releases/download/voicevox_onnxruntime-1.17.3/voicevox_onnxruntime-ios-xcframework-1.17.3.zip

### macOS

voicevox_core の downloader を使って、macOS 用の libvoicevox_core.dylib, libvoicevox_onnxruntime.dylib を取得します。
その後、ダウンロードしたファイルを Xcode のプロジェクトに追加します。

## Notice

- 各種 model の利用時は、[VOICEVOX](https://voicevox.hiroshiba.jp/) の利用規約に従ってください。

## Note

macOSの場合、SpeechSynthesisView の ONNX Runtime の初期化部分で、onnxruntime への絶対パスを指定する必要があります。
