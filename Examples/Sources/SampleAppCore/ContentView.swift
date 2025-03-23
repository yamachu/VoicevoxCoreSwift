import SwiftUI
import VoicevoxCoreSwift

public struct ContentView: View {
    @StateObject private var voicevoxEnvironmentObject = VoicevoxEnvironmentObject()

    public var body: some View {
        VStack {
            Text(VoicevoxCore.version)

            DictionaryDownloaderView()
                .padding()
                .environmentObject(voicevoxEnvironmentObject)
            VoiceModelsView()
                .environmentObject(voicevoxEnvironmentObject)
            SpeechSynthesisView()
                .environmentObject(voicevoxEnvironmentObject)
        }
        .padding()
    }

    public init() {
    }
}

#Preview {
    ContentView()
}
