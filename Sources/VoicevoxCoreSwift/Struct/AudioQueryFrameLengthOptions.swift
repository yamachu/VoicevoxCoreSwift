#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class AudioQueryFrameLengthOptions {
    internal fileprivate(set) var options: VoicevoxAudioQueryFrameLengthOptions

    public var enableInterrogativeUpspeak: Bool {
        get {
            return options.enable_interrogative_upspeak
        }
        set {
            options.enable_interrogative_upspeak = newValue
        }
    }

    private init(options: VoicevoxAudioQueryFrameLengthOptions) {
        self.options = options
    }

    public static func defaultOptions() -> AudioQueryFrameLengthOptions {
        let options = voicevox_make_default_audio_query_frame_length_options()
        return AudioQueryFrameLengthOptions(options: options)
    }
}
