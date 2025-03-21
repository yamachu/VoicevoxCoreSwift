import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class OpenJtalkRc {
    internal fileprivate(set) var pointer: OpaquePointer?

    fileprivate init(pointer: OpaquePointer?) {
        self.pointer = pointer
    }

    public static func New(openJtalkDicDir: String) throws -> OpenJtalkRc {
        var pointer: OpaquePointer?
        let result = voicevox_open_jtalk_rc_new(openJtalkDicDir, &pointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return OpenJtalkRc(pointer: pointer)
    }

    public func useUserDict(userDict: UserDict) throws {
        let result = voicevox_open_jtalk_rc_use_user_dict(self.pointer, userDict.pointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func analyze(text: String) throws -> String {
        var outputJson: UnsafeMutablePointer<CChar>?
        let result = voicevox_open_jtalk_rc_analyze(self.pointer, text, &outputJson)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        defer {
            voicevox_json_free(outputJson)
        }
        return String(cString: outputJson!)
    }

    deinit {
        if pointer != nil {
            voicevox_open_jtalk_rc_delete(pointer)
            pointer = nil
        }
    }
}
