import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class TtsOptions {
    internal fileprivate(set) var options: VoicevoxTtsOptions

    public var enableInterrogativeUpspeak: Bool {
        get {
            return options.enable_interrogative_upspeak
        }
        set {
            options.enable_interrogative_upspeak = newValue
        }
    }

    private init(options: VoicevoxTtsOptions) {
        self.options = options
    }

    public static func defaultOptions() -> TtsOptions {
        let options = voicevox_make_default_tts_options()
        return TtsOptions(options: options)
    }
}
