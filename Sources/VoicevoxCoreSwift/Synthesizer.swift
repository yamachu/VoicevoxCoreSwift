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

    public func loadVoiceModel(
        model: VoiceModel, options: LoadVoiceModelOptions = .defaultOptions()
    ) throws {
        let result = voicevox_synthesizer_load_voice_model(
            self.pointer, model.pointer, options.options)
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

    public func tts(text: String, styleId: StyleId, options: TtsOptions) throws -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0

        let result = voicevox_synthesizer_tts(
            self.pointer, text, styleId.rawValue, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }

        defer {
            if let wavPointer = wavPointer {
                voicevox_bytes_free(wavPointer)
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
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer)
    }

    public func createAudioQueryFromKana(kana: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_audio_query_from_kana(
            self.pointer, kana, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAudioQuery(text: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_audio_query(
            self.pointer, text, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAccentPhrasesFromKana(kana: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_accent_phrases_from_kana(
            self.pointer, kana, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createAccentPhrases(text: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_accent_phrases(
            self.pointer, text, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replaceMoraData(accentPhrasesJson: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_mora_data(
            self.pointer, accentPhrasesJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replacePhonemeLength(accentPhrasesJson: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_phoneme_length(
            self.pointer, accentPhrasesJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func replaceMoraPitch(accentPhrasesJson: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_replace_mora_pitch(
            self.pointer, accentPhrasesJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func synthesis(audioQueryJson: String, styleId: StyleId, options: SynthesisOptions) throws
        -> Data
    {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        let result = voicevox_synthesizer_synthesis(
            self.pointer, audioQueryJson, styleId.rawValue, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            if let wavPointer = wavPointer {
                voicevox_bytes_free(wavPointer)
            }
        }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    public func ttsFromKana(kana: String, styleId: StyleId, options: TtsOptions) throws -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        let result = voicevox_synthesizer_tts_from_kana(
            self.pointer, kana, styleId.rawValue, options.options, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            if let wavPointer = wavPointer {
                voicevox_bytes_free(wavPointer)
            }
        }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    public func createSingFrameAudioQuery(scoreJson: String, styleId: StyleId) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_sing_frame_audio_query(
            self.pointer, scoreJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createSingFrameF0(scoreJson: String, frameAudioQueryJson: String, styleId: StyleId)
        throws -> String
    {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_sing_frame_f0(
            self.pointer, scoreJson, frameAudioQueryJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func createSingFrameVolume(
        scoreJson: String, frameAudioQueryJson: String, styleId: StyleId
    ) throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_synthesizer_create_sing_frame_volume(
            self.pointer, scoreJson, frameAudioQueryJson, styleId.rawValue, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer { voicevox_string_free(jsonPointer) }
        return String(cString: jsonPointer!)
    }

    public func frameSynthesis(frameAudioQueryJson: String, styleId: StyleId) throws -> Data {
        var wavPointer: UnsafeMutablePointer<UInt8>?
        var wavLength: UInt = 0
        let result = voicevox_synthesizer_frame_synthesis(
            self.pointer, frameAudioQueryJson, styleId.rawValue, &wavLength, &wavPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            if let wavPointer = wavPointer {
                voicevox_bytes_free(wavPointer)
            }
        }
        return Data(bytes: wavPointer!, count: Int(wavLength))
    }

    public func createAudioFeature(
        audioQueryJson: String, styleId: StyleId, options: SynthesisOptions = .defaultOptions()
    ) throws -> AudioFeature {
        var audioFeaturePointer: OpaquePointer?
        let result = voicevox_synthesizer_create_audio_feature(
            self.pointer, audioQueryJson, styleId.rawValue, options.options, &audioFeaturePointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        guard let audioFeaturePointer = audioFeaturePointer else {
            throw NSError(
                domain: "Synthesizer", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create audio feature"])
        }
        return AudioFeature(pointer: audioFeaturePointer)
    }

    /// Returns signed 16-bit little-endian PCM, not a WAV container.
    public func render(audioFeatureSlice: AudioFeatureSlice) throws -> Data {
        return try withExtendedLifetime(audioFeatureSlice) {
            var pcmPointer: UnsafeMutablePointer<UInt8>?
            var pcmLength: UInt = 0
            let result = voicevox_synthesizer_render(
                self.pointer, audioFeatureSlice.value, &pcmLength, &pcmPointer)
            if result != ResultCode.OK.rawValue {
                throw ResultCodeError.from(ResultCode(rawValue: result)!)
            }

            // Empty PCM uses a static sentinel that must not be freed.
            guard pcmLength > 0 else {
                return Data()
            }
            defer { voicevox_bytes_free(pcmPointer) }
            guard let pcmPointer = pcmPointer else {
                throw NSError(
                    domain: "Synthesizer", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to render audio feature"])
            }
            return Data(bytes: pcmPointer, count: Int(pcmLength))
        }
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func tts(text: String, styleId: UInt32, options: TtsOptions) throws -> Data {
        try tts(text: text, styleId: StyleId(rawValue: styleId), options: options)
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createAudioQueryFromKana(kana: String, styleId: UInt32) throws -> String {
        try createAudioQueryFromKana(kana: kana, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createAudioQuery(text: String, styleId: UInt32) throws -> String {
        try createAudioQuery(text: text, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createAccentPhrasesFromKana(kana: String, styleId: UInt32) throws -> String {
        try createAccentPhrasesFromKana(kana: kana, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createAccentPhrases(text: String, styleId: UInt32) throws -> String {
        try createAccentPhrases(text: text, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func replaceMoraData(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        try replaceMoraData(
            accentPhrasesJson: accentPhrasesJson, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func replacePhonemeLength(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        try replacePhonemeLength(
            accentPhrasesJson: accentPhrasesJson, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func replaceMoraPitch(accentPhrasesJson: String, styleId: UInt32) throws -> String {
        try replaceMoraPitch(
            accentPhrasesJson: accentPhrasesJson, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func synthesis(
        audioQueryJson: String, styleId: UInt32, options: SynthesisOptions
    ) throws -> Data {
        try synthesis(
            audioQueryJson: audioQueryJson, styleId: StyleId(rawValue: styleId), options: options)
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func ttsFromKana(kana: String, styleId: UInt32, options: TtsOptions) throws -> Data {
        try ttsFromKana(kana: kana, styleId: StyleId(rawValue: styleId), options: options)
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createSingFrameAudioQuery(scoreJson: String, styleId: UInt32) throws -> String {
        try createSingFrameAudioQuery(scoreJson: scoreJson, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createSingFrameF0(
        scoreJson: String, frameAudioQueryJson: String, styleId: UInt32
    ) throws -> String {
        try createSingFrameF0(
            scoreJson: scoreJson, frameAudioQueryJson: frameAudioQueryJson,
            styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createSingFrameVolume(
        scoreJson: String, frameAudioQueryJson: String, styleId: UInt32
    ) throws -> String {
        try createSingFrameVolume(
            scoreJson: scoreJson, frameAudioQueryJson: frameAudioQueryJson,
            styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func frameSynthesis(frameAudioQueryJson: String, styleId: UInt32) throws -> Data {
        try frameSynthesis(
            frameAudioQueryJson: frameAudioQueryJson, styleId: StyleId(rawValue: styleId))
    }

    @available(*, deprecated, message: "Use the overload that accepts StyleId.")
    public func createAudioFeature(
        audioQueryJson: String, styleId: UInt32, options: SynthesisOptions = .defaultOptions()
    ) throws -> AudioFeature {
        try createAudioFeature(
            audioQueryJson: audioQueryJson, styleId: StyleId(rawValue: styleId), options: options)
    }

    deinit {
        if pointer != nil {
            voicevox_synthesizer_delete(pointer)
            pointer = nil
        }
    }
}
