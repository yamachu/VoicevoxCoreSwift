import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class Onnxruntime {
    internal fileprivate(set) var pointer: OpaquePointer?

    // NOTE: Synthesizerからも呼ばれるためinternalにしている
    internal init(pointer: OpaquePointer?) {
        self.pointer = pointer
    }

    public static func Get() -> Onnxruntime? {
        let pointer = voicevox_onnxruntime_get()
        if pointer == nil {
            return nil
        }
        return Onnxruntime(pointer: pointer)
    }

    public func createSupportedDevicesJson() throws -> String {
        var outputJson: UnsafeMutablePointer<CChar>?
        let result = voicevox_onnxruntime_create_supported_devices_json(pointer, &outputJson)
        guard result == VOICEVOX_RESULT_OK.rawValue else {
            throw ResultCodeError.from(.init(rawValue: result)!)
        }
        defer {
            voicevox_json_free(outputJson)
        }
        return String(cString: outputJson!)
    }
}

#if os(macOS)
    extension Onnxruntime {
        public static func LoadOnce(options: LoadOnnxruntimeOptions) throws -> Onnxruntime {
            var pointer: OpaquePointer? = nil
            let result = voicevox_onnxruntime_load_once(options.options, &pointer)
            if result != VOICEVOX_RESULT_OK.rawValue {
                throw ResultCodeError.from(ResultCode(rawValue: result)!)
            }
            return Onnxruntime(pointer: pointer)
        }

        public static var VersionedFilename: String {
            return String(cString: voicevox_get_onnxruntime_lib_versioned_filename())
        }

        public static var UnversionedFilename: String {
            return String(cString: voicevox_get_onnxruntime_lib_unversioned_filename())
        }
    }
#elseif os(iOS)
    extension Onnxruntime {
        public static func InitOnce() throws -> Onnxruntime {
            var pointer: OpaquePointer? = nil
            let result = voicevox_onnxruntime_init_once(&pointer)
            if result != VOICEVOX_RESULT_OK.rawValue {
                throw ResultCodeError.from(ResultCode(rawValue: result)!)
            }
            return Onnxruntime(pointer: pointer)
        }
    }
#endif
