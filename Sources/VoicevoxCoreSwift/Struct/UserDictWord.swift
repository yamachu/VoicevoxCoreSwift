import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class UserDictWord {
    internal fileprivate(set) var word: VoicevoxUserDictWord

    private var _surface: String?
    private var _pronunciation: String?

    public var surface: String {
        get {
            return String(cString: word.surface)
        }
        set {
            if _surface != nil {
                free(UnsafeMutablePointer(mutating: word.surface))
            }
            _surface = newValue
            newValue.withCString { cString in
                word.surface = UnsafePointer(strdup(cString))
            }
        }
    }

    public var pronunciation: String {
        get {
            return String(cString: word.pronunciation)
        }
        set {
            if _pronunciation != nil {
                free(UnsafeMutablePointer(mutating: word.pronunciation))
            }
            _pronunciation = newValue
            newValue.withCString { cString in
                word.pronunciation = UnsafePointer(strdup(cString))
            }
        }
    }

    public var accentType: UInt {
        get {
            return UInt(word.accent_type)
        }
        set {
            word.accent_type = uintptr_t(newValue)
        }
    }

    public var wordType: UserDictWordType {
        get {
            return UserDictWordType(rawValue: word.word_type)!
        }
        set {
            word.word_type = newValue.rawValue
        }
    }

    public var priority: UInt {
        get {
            return UInt(word.priority)
        }
        set {
            word.priority = UInt32(newValue)
        }
    }

    private init(word: VoicevoxUserDictWord, surface: String, pronunciation: String) {
        self.word = word
        self._surface = surface
        self._pronunciation = pronunciation
    }

    public static func make(surface: String, pronunciation: String, accentType: UInt) -> UserDictWord {
        let word = voicevox_user_dict_word_make(surface, pronunciation, uintptr_t(accentType))
        return UserDictWord(word: word, surface: surface, pronunciation: pronunciation)
    }

    deinit {
        if let currentSurface = word.surface {
            free(UnsafeMutablePointer(mutating: currentSurface))
        }
        if let currentPronunciation = word.pronunciation {
            free(UnsafeMutablePointer(mutating: currentPronunciation))
        }
    }
}
