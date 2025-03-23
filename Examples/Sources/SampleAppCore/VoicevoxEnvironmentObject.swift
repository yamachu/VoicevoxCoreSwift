import Foundation

class VoicevoxEnvironmentObject: ObservableObject {
    @Published var isDictionaryInstalled: Bool = false
    @Published var selectedVoiceModel: VoiceModel? = nil

}
