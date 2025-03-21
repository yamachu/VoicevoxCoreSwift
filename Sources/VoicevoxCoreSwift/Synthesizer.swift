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

    deinit {
        if pointer != nil {
            voicevox_synthesizer_delete(pointer)
            pointer = nil
        }
    }

    // TODO: Impl
    // voicevox_synthesizer_get_onnxruntime
    // voicevox_synthesizer_is_gpu_mode
    // voicevox_synthesizer_is_loaded_voice_model
    // voicevox_synthesizer_create_metas_json
    // voicevox_onnxruntime_create_supported_devices_json
    // voicevox_synthesizer_create_audio_query_from_kana
    // voicevox_synthesizer_create_audio_query
    // voicevox_synthesizer_create_accent_phrases_from_kana
    // voicevox_synthesizer_create_accent_phrases
    // voicevox_synthesizer_replace_mora_data
    // voicevox_synthesizer_replace_phoneme_length
    // voicevox_synthesizer_replace_mora_pitch
    // voicevox_synthesizer_synthesis
    // voicevox_synthesizer_tts_from_kana

}
