#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public final class AudioFeature {
    internal let pointer: OpaquePointer

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    public var length: UInt {
        return withExtendedLifetime(self) {
            voicevox_audio_feature_len(pointer)
        }
    }

    public var isEmpty: Bool {
        return withExtendedLifetime(self) {
            voicevox_audio_feature_is_empty(pointer)
        }
    }

    public func slice(clamp: Bool = false, allowStartExceedsEnd: Bool = false) -> AudioFeatureSlice {
        let value = voicevox_audio_feature_slice_new(pointer, clamp, allowStartExceedsEnd)
        return AudioFeatureSlice(value: value, audioFeature: self)
    }

    public func slice(
        startInclusive: UInt, end: UInt, endIsInclusive: Bool = false,
        clamp: Bool = false, allowStartExceedsEnd: Bool = false
    ) throws -> AudioFeatureSlice {
        var value = VoicevoxAudioFeatureSlice()
        let result = voicevox_audio_feature_slice(
            pointer, startInclusive, end, endIsInclusive, clamp, allowStartExceedsEnd, &value)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return AudioFeatureSlice(value: value, audioFeature: self)
    }

    deinit {
        voicevox_audio_feature_delete(pointer)
    }
}
