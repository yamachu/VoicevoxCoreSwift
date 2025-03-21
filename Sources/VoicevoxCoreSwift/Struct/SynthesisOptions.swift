import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class SynthesisOptions {
    internal fileprivate(set) var options: VoicevoxSynthesisOptions

    public var enableInterrogativeUpspeak: Bool {
        get {
            return options.enable_interrogative_upspeak
        }
        set {
            options.enable_interrogative_upspeak = newValue
        }
    }

    private init(options: VoicevoxSynthesisOptions) {
        self.options = options
    }

    public static func defaultOptions() -> SynthesisOptions {
        let options = voicevox_make_default_synthesis_options()
        return SynthesisOptions(options: options)
    }
}
