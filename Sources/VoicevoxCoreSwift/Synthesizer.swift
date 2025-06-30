import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class Synthesizer {
    internal fileprivate(set) var pointer: OpaquePointer?

    fileprivate init(pointer: OpaquePointer?) {
        self.pointer = pointer
    }

    public static func New(
        onnxruntime: Onnxruntime, openJtalk: OpenJtalkRc, options: InitializeOptions
    ) throws -> Synthesizer {
        var pointer: OpaquePointer?
        let result = voicevox_synthesizer_new(
            onnxruntime.pointer, openJtalk.pointer, options.options, &pointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return Synthesizer(pointer: pointer)
    }

    public func loadVoiceModel(model: VoiceModel) throws {
        let result = voicevox_synthesizer_load_voice_model(self.pointer, model.pointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func unloadVoiceModel(modelId: VoiceModelId) throws {
        var mutableModelId = modelId
        let result = voicevox_synthesizer_unload_voice_model(self.pointer, &mutableModelId.bytes)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func tts(text: String, styleId: UInt32, options: TtsOptions) throws -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0

        let result = voicevox_synthesizer_tts(
            self.pointer, text, styleId, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }

        defer {
            if let wavPointer = wavPointer {
                voicevox_wav_free(wavPointer)
            }
        }

        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    public func getOnnxruntime() -> Onnxruntime? {
        guard let onnxruntimePointer = voicevox_synthesizer_get_onnxruntime(self.pointer) else {
            return nil
        }
        return Onnxruntime(pointer: onnxruntimePointer)
    }

    public func isGpuMode() -> Bool {
        return voicevox_synthesizer_is_gpu_mode(self.pointer)
    }

    public func isLoadedVoiceModel(modelId: VoiceModelId) -> Bool {
        var mutableModelId = modelId
        return voicevox_synthesizer_is_loaded_voice_model(self.pointer, &mutableModelId.bytes)
    }

    public func createMetasJson() throws -> String {
        guard let jsonPointer = voicevox_synthesizer_create_metas_json(self.pointer) else {
            throw ResultCodeError.from(.INVALID_MODEL_DATA_ERROR)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer)
    }

    public func createAudioQueryFromKana(kana: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_audio_query_from_kana(
            self.pointer, kana, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAudioQuery(text: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_audio_query(
            self.pointer, text, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAccentPhrasesFromKana(kana: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_accent_phrases_from_kana(
            self.pointer, kana, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAccentPhrases(text: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_accent_phrases(
            self.pointer, text, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replaceMoraData(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_mora_data(
            self.pointer, accentPhrasesJson, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replacePhonemeLength(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_phoneme_length(
            self.pointer, accentPhrasesJson, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replaceMoraPitch(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_mora_pitch(
            self.pointer, accentPhrasesJson, styleId, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func synthesis(audioQueryJson: String, styleId: UInt32, options: SynthesisOptions) throws
        -> Data
    {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        let result = voicevox_synthesizer_synthesis(
            self.pointer, audioQueryJson, styleId, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            if let wavPointer = wavPointer {
                voicevox_wav_free(wavPointer)
            }
        }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }
    
    public func createAudioQueryfromAccentPhrases(accentPhraseJson: String, styleId: UInt32) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_audio_query_create_from_accent_phrases(
            accentPhraseJson, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func ttsFromKana(kana: String, styleId: UInt32, options: TtsOptions) throws -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        let result = voicevox_synthesizer_tts_from_kana(
            self.pointer, kana, styleId, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            if let wavPointer = wavPointer {
                voicevox_wav_free(wavPointer)
            }
        }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    deinit {
        if pointer != nil {
            voicevox_synthesizer_delete(pointer)
            pointer = nil
        }
    }
}
