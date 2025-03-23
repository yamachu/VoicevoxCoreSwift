# SampleApp

VoicevoxCoreSwift を使ったサンプルアプリ。

## Requirements

- native ディレクトリに 2つの xcframework を配置します
  - https://github.com/VOICEVOX/voicevox_core/releases/download/0.16.0-preview.1/voicevox_core-ios-xcframework-cpu-0.16.0-preview.1.zip
  - https://github.com/VOICEVOX/onnxruntime-builder/releases/download/voicevox_onnxruntime-1.17.3/voicevox_onnxruntime-ios-xcframework-1.17.3.zip

## Notice

- 各種 model の利用時は、[VOICEVOX](https://voicevox.hiroshiba.jp/) の利用規約に従ってください。

## Note

Debug 実行を行うことが出来ないため、Schema の編集で Debug executable をオフにする必要があります。
しかし voicevox_onnxruntime ではなく、onnxruntime を使用し、voicevox_core リポジトリにある sample.vvm を使用することでデバッグ実行が可能となります。

iOSの場合、voicevox_core.xframework に対して少し変更を加える必要があります。

```sh
$ install_name_tool -change @rpath/voicevox_onnxruntime.framework/voicevox_onnxruntime @rpath/onnxruntime.framework/onnxruntime voicevox_core.xcframework/ios-arm64/voicevox_core.framework/voicevox_core
$ install_name_tool -change @rpath/voicevox_onnxruntime.framework/voicevox_onnxruntime @rpath/onnxruntime.framework/onnxruntime voicevox_core.xcframework/ios-arm64_x86_64-simulator/voicevox_core.framework/voicevox_core
```

macOSの場合、SpeechSynthesisView の ONNX Runtime の初期化部分で、onnxruntime への絶対パスを指定する必要があります。
