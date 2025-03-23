import AVFoundation
import SwiftUI
import VoicevoxCoreSwift

struct SpeechSynthesisView: View {
    @EnvironmentObject var voicevoxEnvironment: VoicevoxEnvironmentObject
    @State private var inputText: String = ""
    @State private var isSynthesizing: Bool = false

    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            TextField("Enter text to synthesize", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                self.isSynthesizing = true
                synthesizeSpeech(text: inputText)
                self.isSynthesizing = false
            }) {
                Text("Synthesize")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(
                inputText.isEmpty || voicevoxEnvironment.selectedVoiceModel == nil || isSynthesizing
            )
        }
        .padding()
    }

    private func synthesizeSpeech(text: String) {
        guard
            let dictPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(dictionaryExtractPath),
            let modelBasePath = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            )
            .first?
            .appendingPathComponent(modelsDownloadPath),
            let model = voicevoxEnvironment.selectedVoiceModel
        else {
            print("Failed to get dictionary path")
            return
        }

        let modelPath = modelBasePath.appendingPathComponent(model.vvm)
        let styleId = model.styleId

        // 1. OpenJTalk辞書の初期化
        let openJtalk = try? OpenJtalkRc.New(openJtalkDicDir: dictPath.path)
        guard let openJtalk = openJtalk else {
            print("Failed to initialize OpenJTalk")
            return
        }
        // 2. ONNX Runtimeの初期化
        #if os(iOS)
            let onnxruntime = try? Onnxruntime.InitOnce()
        #else
            var option = LoadOnnxruntimeOptions.defaultOptions()

            // アプリケーションとしてビルドした際、~.app/Contents/Frameworks/voicevox_onnxruntime.framework/voicevox_onnxruntime にvoicevox_onnxruntime が配置される
            // しかし、voicevox_core内部でdlopenする際にFrameworks以下は探索しないため、絶対パスを指定している
            let filename =
                Bundle.main.bundlePath
                + "/Contents/Frameworks/voicevox_onnxruntime.framework/voicevox_onnxruntime"
            option.filename = filename
            let onnxruntime = try? Onnxruntime.LoadOnce(options: option)
        #endif
        guard let onnxruntime = onnxruntime else {
            print("Failed to initialize Onnxruntime")
            return
        }

        // 3. Synthesizerの初期化
        var initializeOptions = InitializeOptions.defaultOptions()
        let synthesizer = try? Synthesizer.New(
            onnxruntime: onnxruntime, openJtalk: openJtalk, options: initializeOptions)
        guard let synthesizer = synthesizer else {
            print("Failed to initialize Synthesizer")
            return
        }

        // 4. 音声モデルの読み込み
        let voiceModel = try? VoicevoxCoreSwift.VoiceModel.open(
            path: modelPath.standardizedFileURL.path)
        guard let voiceModel = voiceModel else {
            print("Failed to open voice model")
            return
        }

        // NOTE: Debug executableしてる状態で、かつVoicevoxOnnxruntimeを使用しているとクラッシュする
        try? synthesizer.loadVoiceModel(model: voiceModel)

        // 5. TTSの実行
        var ttsOptions = TtsOptions.defaultOptions()
        let data = try? synthesizer.tts(text: text, styleId: UInt32(styleId), options: ttsOptions)
        guard let wavData = data else {
            print("Failed to synthesize speech")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play WAV data: \(error.localizedDescription)")
        }

        return
    }

}
