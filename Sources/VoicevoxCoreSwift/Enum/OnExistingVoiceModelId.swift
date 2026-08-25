import Foundation

public enum OnExistingVoiceModelId: Int32 {
    /**
     * 同じIDの音声モデルが読み込まれている場合はエラーにする
     */
    case ERROR = 0
    /**
     * 同じIDの音声モデルを再読み込みする
     */
    case RELOAD = 1
    /**
     * 同じIDの音声モデルが読み込まれている場合は何もしない
     */
    case SKIP = 2
}
