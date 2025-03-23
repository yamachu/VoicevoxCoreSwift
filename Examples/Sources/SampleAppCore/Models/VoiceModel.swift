import Foundation

public struct VoiceModels: Decodable {
    let models: [ModelContainer]
}

struct ModelContainer: Decodable {
    let vvm: String
    let id: String
    let metas: [ModelMeta]
}

struct ModelMeta: Decodable {
    let name: String
    let styles: [ModelStyle]
    let speaker_uuid: String
    let version: String
    let order: Int
}

struct ModelStyle: Decodable {
    let name: String
    let id: Int
    let order: Int
}

// アプリで使用するモデル
public struct VoiceModel: Identifiable {
    public let vvm: String
    public let vvmUuid: String

    public let name: String
    public let style: String
    public let styleId: Int
    public let speakerUuid: String

    public var id: String { "\(styleId)" }
    public var displayName: String { "\(name) - \(style)" }
}

extension VoiceModels {
    public func toVoiceModelArray() -> [VoiceModel] {
        var results = [VoiceModel]()

        for modelContainer in models {
            for meta in modelContainer.metas {
                for style in meta.styles {
                    let model = VoiceModel(
                        vvm: modelContainer.vvm,
                        vvmUuid: modelContainer.id,
                        name: meta.name,
                        style: style.name,
                        styleId: style.id,
                        speakerUuid: meta.speaker_uuid
                    )
                    results.append(model)
                }
            }
        }

        return results
    }
}
