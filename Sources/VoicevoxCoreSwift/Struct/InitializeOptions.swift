import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

public class InitializeOptions {
    internal fileprivate(set) var options: VoicevoxInitializeOptions

    public var accelerationMode: AccelerationMode {
        get {
            return AccelerationMode(rawValue: options.acceleration_mode)!
        }
        set {
            options.acceleration_mode = newValue.rawValue
        }
    }

    public var cpuNumThreads: UInt16 {
        get {
            return options.cpu_num_threads
        }
        set {
            options.cpu_num_threads = newValue
        }
    }

    private init(options: VoicevoxInitializeOptions) {
        self.options = options
    }

    public static func defaultOptions() -> InitializeOptions {
        let options = voicevox_make_default_initialize_options()
        return InitializeOptions(options: options)
    }
}
