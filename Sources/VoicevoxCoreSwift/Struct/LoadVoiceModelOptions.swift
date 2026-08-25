import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class LoadVoiceModelOptions {
    internal fileprivate(set) var options: VoicevoxLoadVoiceModelOptions

    public var onExisting: OnExistingVoiceModelId {
        get {
            OnExistingVoiceModelId(rawValue: options.on_existing)!
        }
        set {
            options.on_existing = newValue.rawValue
        }
    }

    private init(options: VoicevoxLoadVoiceModelOptions) {
        self.options = options
    }

    public static func defaultOptions() -> LoadVoiceModelOptions {
        LoadVoiceModelOptions(options: voicevox_make_default_load_voice_model_options())
    }
}
