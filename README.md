# VoicevoxCoreSwift

Unofficial Swift wrapper for voicevox_core.

## About

型定義とラップ部分のみを提供するライブラリ。
アプリケーションに組み込む際は、別途 voicevox_core.xcframework などを組み込む必要があります。

binaryTargetに依存していないため、ヘッダに変更がない限り自由に voicevox_core.xcframework のバージョンを上げることが可能です。

## Supported Platforms

- iOS
- macOS

## Features

- 0.16.0-preview.1で提供されるAPIをラップ

### Future work

- AccentPhrasesなどのjson形式で渡されるものを型で表現する
  - ref: https://github.com/VOICEVOX/voicevox_core/issues/975

## License

MIT License

### Third-Party Licenses

This repository contains files that are licensed by the original authors under the MIT License. Please refer to the source of each file for license details.

- [Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h](https://github.com/VOICEVOX/voicevox_core/blob/main/LICENSE)
- [Sources/VoicevoxCoreSwiftMacOS/include/voicevox_core.h](https://github.com/VOICEVOX/voicevox_core/blob/main/LICENSE)
