import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public struct VoiceModelId {
    public var bytes:
        (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

    public init() {
        self.bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }
}

public class VoiceModel {
    internal fileprivate(set) var pointer: OpaquePointer?

    fileprivate init(pointer: OpaquePointer?) {
        self.pointer = pointer
    }

    public static func open(path: String) throws -> VoiceModel {
        var pointer: OpaquePointer?
        let result = voicevox_voice_model_file_open(path, &pointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return VoiceModel(pointer: pointer)
    }

    public var id: VoiceModelId {
        var modelId = VoiceModelId()

        voicevox_voice_model_file_id(self.pointer, &modelId.bytes)
        return modelId
    }

    public var metasJson: String {
        guard let jsonPointer = voicevox_voice_model_file_create_metas_json(pointer) else {
            return ""
        }
        defer { voicevox_json_free(jsonPointer) }
        return String(cString: jsonPointer)
    }

    deinit {
        if pointer != nil {
            voicevox_voice_model_file_delete(pointer)
            pointer = nil
        }
    }
}
