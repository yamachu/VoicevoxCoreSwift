import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public struct WordUuid {
    public var bytes:
        (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

    public init() {
        self.bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }
}

public class UserDict {
    internal fileprivate(set) var pointer: OpaquePointer?

    fileprivate init(pointer: OpaquePointer?) {
        self.pointer = pointer
    }

    public static func New() -> UserDict {
        let pointer = voicevox_user_dict_new()
        return UserDict(pointer: pointer)
    }

    public func load(path: String) throws {
        let result = voicevox_user_dict_load(self.pointer, path)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func addWord(word: UserDictWord) throws -> WordUuid {
        var uuid = WordUuid()
        var wordPointer = word.word
        let result = voicevox_user_dict_add_word(self.pointer, &wordPointer, &uuid.bytes)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return uuid
    }

    public func updateWord(uuid: WordUuid, word: UserDictWord) throws {
        var uuidBytes = uuid.bytes
        var wordPointer = word.word
        let result = voicevox_user_dict_update_word(self.pointer, &uuidBytes, &wordPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func removeWord(uuid: WordUuid) throws {
        var uuidBytes = uuid.bytes
        let result = voicevox_user_dict_remove_word(self.pointer, &uuidBytes)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    public func toJson() throws -> String {
        var jsonPointer: UnsafeMutablePointer<CChar>?
        let result = voicevox_user_dict_to_json(self.pointer, &jsonPointer)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }

        defer {
            if let jsonPointer = jsonPointer {
                voicevox_json_free(jsonPointer)
            }
        }

        return String(cString: jsonPointer!)
    }

    public func save(path: String) throws {
        let result = voicevox_user_dict_save(self.pointer, path)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
    }

    deinit {
        if pointer != nil {
            voicevox_user_dict_delete(pointer)
            pointer = nil
        }
    }
}
