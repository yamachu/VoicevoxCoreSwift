#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public struct VoicevoxCore {
    public static var version: String {
        return String(cString: voicevox_get_version())
    }
}
