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
                voicevox_string_free(resultPointer)
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

    public static func audioQueryFrameLength(
        audioQueryJson: String, options: AudioQueryFrameLengthOptions = .defaultOptions()
    ) throws -> UInt {
        var frameLength: UInt = 0
        let result = voicevox_audio_query_frame_length(
            audioQueryJson, options.options, &frameLength)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return frameLength
    }

    public static func wavFromS16le(pcm: Data, samplingRate: UInt32, isStereo: Bool) -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        var emptyByte: UInt8 = 0
        // Even empty PCM requires a non-null pointer.
        withUnsafePointer(to: &emptyByte) { emptyPointer in
            pcm.withUnsafeBytes { buffer in
                voicevox_wav_from_s16le(
                    UInt(buffer.count),
                    buffer.bindMemory(to: UInt8.self).baseAddress ?? emptyPointer,
                    samplingRate, isStereo, &wavLength, &wavPointer)
            }
        }
        defer { voicevox_bytes_free(wavPointer) }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    public static func validateAudioQuery(audioQueryJson: String) throws {
        let result = voicevox_audio_query_validate(audioQueryJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateAccentPhrase(accentPhraseJson: String) throws {
        let result = voicevox_accent_phrase_validate(accentPhraseJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateMora(moraJson: String) throws {
        let result = voicevox_mora_validate(moraJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateScore(scoreJson: String) throws {
        let result = voicevox_score_validate(scoreJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateNote(noteJson: String) throws {
        let result = voicevox_note_validate(noteJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateFrameAudioQuery(frameAudioQueryJson: String) throws {
        let result = voicevox_frame_audio_query_validate(frameAudioQueryJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func validateFramePhoneme(framePhonemeJson: String) throws {
        let result = voicevox_frame_phoneme_validate(framePhonemeJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public static func ensureCompatible(scoreJson: String, frameAudioQueryJson: String) throws {
        let result = voicevox_ensure_compatible(scoreJson, frameAudioQueryJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }
}
