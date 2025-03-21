import Foundation

#if os(macOS)
    @_implementationOnly import VoicevoxCoreSwiftMAC
#elseif os(iOS)
    @_implementationOnly import VoicevoxCoreSwiftIOS
#endif

#if os(macOS)
    public class LoadOnnxruntimeOptions {
        internal fileprivate(set) var options: VoicevoxLoadOnnxruntimeOptions
        private var _filename: String?

        public var filename: String {
            get {
                return String(cString: options.filename)
            }
            set {
                if _filename != nil {
                    free(UnsafeMutablePointer(mutating: options.filename))
                }
                _filename = newValue
                newValue.withCString { cString in
                    options.filename = UnsafePointer(strdup(cString))
                }
            }
        }

        private init(options: VoicevoxLoadOnnxruntimeOptions) {
            self.options = options
        }

        public static func defaultOptions() -> LoadOnnxruntimeOptions {
            let options = voicevox_make_default_load_onnxruntime_options()
            return LoadOnnxruntimeOptions(options: options)
        }

        deinit {
            if options.filename != nil {
                free(UnsafeMutablePointer(mutating: options.filename))
            }
        }
    }
#endif
