import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public enum ResultCode: Int32, Error {
    /**
     * 成功
     */
    case OK = 0
    /**
     * open_jtalk辞書ファイルが読み込まれていない
     */
    case NOT_LOADED_OPENJTALK_DICT_ERROR = 1
    /**
     * サポートされているデバイス情報取得に失敗した
     */
    case GET_SUPPORTED_DEVICES_ERROR = 3
    /**
     * GPUモードがサポートされていない
     */
    case GPU_SUPPORT_ERROR = 4
    /**
     * 推論ライブラリのロードまたは初期化ができなかった
     */
    case INIT_INFERENCE_RUNTIME_ERROR = 29
    /**
     * スタイルIDに対するスタイルが見つからなかった
     */
    case STYLE_NOT_FOUND_ERROR = 6
    /**
     * 音声モデルIDに対する音声モデルが見つからなかった
     */
    case MODEL_NOT_FOUND_ERROR = 7
    /**
     * 推論に失敗した
     */
    case RUN_MODEL_ERROR = 8
    /**
     * 入力テキストの解析に失敗した
     */
    case ANALYZE_TEXT_ERROR = 11
    /**
     * 無効なutf8文字列が入力された
     */
    case INVALID_UTF8_INPUT_ERROR = 12
    /**
     * AquesTalk風記法のテキストの解析に失敗した
     */
    case PARSE_KANA_ERROR = 13
    /**
     * 無効なAudioQuery
     */
    case INVALID_AUDIO_QUERY_ERROR = 14
    /**
     * 無効なAccentPhrase
     */
    case INVALID_ACCENT_PHRASE_ERROR = 15
    /**
     * ZIPファイルを開くことに失敗した
     */
    case OPEN_ZIP_FILE_ERROR = 16
    /**
     * ZIP内のファイルが読めなかった
     */
    case READ_ZIP_ENTRY_ERROR = 17
    /**
     * モデルの形式が不正
     */
    case INVALID_MODEL_HEADER_ERROR = 28
    /**
     * すでに読み込まれている音声モデルを読み込もうとした
     */
    case MODEL_ALREADY_LOADED_ERROR = 18
    /**
     * すでに読み込まれているスタイルを読み込もうとした
     */
    case STYLE_ALREADY_LOADED_ERROR = 26
    /**
     * 無効なモデルデータ
     */
    case INVALID_MODEL_DATA_ERROR = 27
    /**
     * ユーザー辞書を読み込めなかった
     */
    case LOAD_USER_DICT_ERROR = 20
    /**
     * ユーザー辞書を書き込めなかった
     */
    case SAVE_USER_DICT_ERROR = 21
    /**
     * ユーザー辞書に単語が見つからなかった
     */
    case USER_DICT_WORD_NOT_FOUND_ERROR = 22
    /**
     * OpenJTalkのユーザー辞書の設定に失敗した
     */
    case USE_USER_DICT_ERROR = 23
    /**
     * ユーザー辞書の単語のバリデーションに失敗した
     */
    case INVALID_USER_DICT_WORD_ERROR = 24
    /**
     * UUIDの変換に失敗した
     */
    case INVALID_UUID_ERROR = 25
}

extension ResultCode: CustomStringConvertible {
    public var description: String {
        return String(cString: voicevox_error_result_to_message(self.rawValue))
    }
}
