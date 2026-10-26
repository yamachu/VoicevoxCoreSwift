#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public struct AudioFeatureSlice {
    internal let value: VoicevoxAudioFeatureSlice
    // The C slice borrows its audio feature; keep the owner alive for all copies and subslices.
    private let audioFeature: AudioFeature

    internal init(value: VoicevoxAudioFeatureSlice, audioFeature: AudioFeature) {
        self.value = value
        self.audioFeature = audioFeature
    }

    public var startOffset: UInt { value.start_offset }
    public var end: UInt { value.end }
    public var endIsInclusive: Bool { value.end_is_inclusive }
    public var clamp: Bool { value.clamp }
    public var allowStartExceedsEnd: Bool { value.allow_start_exceeds_end }

    public func length() throws -> UInt {
        return try withExtendedLifetime(self) {
            var output: UInt = 0
            let result = voicevox_audio_feature_slice_len(value, &output)
            if result != ResultCode.OK.rawValue {
                throw ResultCodeError.from(ResultCode(rawValue: result)!)
            }
            return output
        }
    }

    public func isEmpty() throws -> Bool {
        return try withExtendedLifetime(self) {
            var output = false
            let result = voicevox_audio_feature_slice_is_empty(value, &output)
            if result != ResultCode.OK.rawValue {
                throw ResultCodeError.from(ResultCode(rawValue: result)!)
            }
            return output
        }
    }

    public func slice(
        startInclusive: UInt, end: UInt, endIsInclusive: Bool = false,
        clamp: Bool = false, allowStartExceedsEnd: Bool = false
    ) throws -> AudioFeatureSlice {
        var output = VoicevoxAudioFeatureSlice()
        let result = voicevox_audio_feature_slice_slice(
            value, startInclusive, end, endIsInclusive, clamp, allowStartExceedsEnd, &output)
        if result != ResultCode.OK.rawValue {
            throw ResultCodeError.from(ResultCode(rawValue: result)!)
        }
        return AudioFeatureSlice(value: output, audioFeature: audioFeature)
    }
}
