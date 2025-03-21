import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public struct VoicevoxCoreUtil {
    public static func createAudioQueryFromAccentPhrases(accentPhrases: String)
        throws -> String /* TODO: Mapping to AccentPhrases struct */
    {
        var resultPointer: UnsafeMutablePointer<CChar>?
        defer {
            if let resultPointer = resultPointer {
                voicevox_json_free(resultPointer)
            }
        }

        let result = voicevox_audio_query_create_from_accent_phrases(
            accentPhrases,
            &resultPointer
        )
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }

        guard let resultPointer = resultPointer else {
            throw NSError(
                domain: "VoicevoxCoreUtil",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to create audio query from accent phrases"
                ]
            )
        }

        let audioQuery = String(cString: resultPointer)

        return audioQuery
    }
}
