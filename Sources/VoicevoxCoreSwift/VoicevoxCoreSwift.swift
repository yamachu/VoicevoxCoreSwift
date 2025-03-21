#if os(macOS)
@_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
@_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class VoicevoxCoreSwift {
    private init() {
    }

    public static func version() -> String {
        return String(cString: voicevox_get_version())
    }
}
