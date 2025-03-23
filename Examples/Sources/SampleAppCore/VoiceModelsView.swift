import SwiftUI

struct VoiceModelsView: View {
    @EnvironmentObject private var voicevoxEnvironmentObject: VoicevoxEnvironmentObject

    @State private var downloadingModel: VoiceModel?
    @State private var expandedVvm: String?

    @State private var models: [VoiceModel] = []
    @State private var downloadedVvms: Set<String> = []

    public var body: some View {
        VStack {
            List {
                ForEach(models.groupedByVvm().sorted(by: { $0.key < $1.key }), id: \.key) {
                    vvm, models in
                    Section(header: sectionHeader(vvm: vvm, models: models)) {
                        if expandedVvm == vvm {
                            ForEach(models) { model in
                                modelRow(model: model)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            loadModels()
            checkDownloadedModels()
        }
    }

    init() {
    }

    private func sectionHeader(vvm: String, models: [VoiceModel]) -> some View {
        HStack {
            Text(vvm)
            Spacer()

            HStack {
                if isModelDownloaded(models.first!) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if downloadingModel?.vvm == vvm {
                    ProgressView()
                } else {
                    Image(systemName: "icloud.and.arrow.down")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                let model = models.first!
                guard !isModelDownloaded(model) else { return }
                downloadingModel = model
                Task {
                    do {
                        try await downloadModel(model)
                    } catch {
                        // エラー処理
                    }
                    downloadingModel = nil
                }
            }
            .padding(.vertical, 8)
            .disabled(downloadingModel != nil)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleExpandedVvm(vvm: vvm)
        }
    }

    private func modelRow(model: VoiceModel) -> some View {
        HStack {
            Text(model.displayName)
            Spacer()
            if voicevoxEnvironmentObject.selectedVoiceModel?.id == model.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            voicevoxEnvironmentObject.selectedVoiceModel = model
        }
    }

    private func toggleExpandedVvm(vvm: String) {
        if expandedVvm == vvm {
            expandedVvm = nil
        } else {
            expandedVvm = vvm
        }
    }

    private func loadModels() {
        guard let bundleUrl = Bundle.module.url(forResource: "models", withExtension: "json"),
            let data = try? Data(contentsOf: bundleUrl),
            let models = try? JSONDecoder().decode(VoiceModels.self, from: data).toVoiceModelArray()
        else {
            print("Failed to load models.")
            return
        }
        self.models = models
    }

    private func checkDownloadedModels() {
        guard
            let downloadedPath = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            )
            .first?
            .appendingPathComponent(modelsDownloadPath),
            let contents = try? FileManager.default.contentsOfDirectory(
                at: downloadedPath, includingPropertiesForKeys: nil)
        else {
            return
        }

        self.downloadedVvms = Set(contents.map { $0.lastPathComponent })
    }

    public func isModelDownloaded(_ model: VoiceModel) -> Bool {
        return self.downloadedVvms.contains(model.vvm)
    }

    public func downloadModel(_ model: VoiceModel) async throws {
        guard
            let destinationURL = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            )
            .first?
            .appendingPathComponent(modelsDownloadPath)
            .appendingPathComponent("\(model.vvm)")
        else {
            return
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return
        }

        guard
            let url = URL(
                string:
                    "https://github.com/VOICEVOX/voicevox_vvm/raw/refs/heads/main/vvms/\(model.vvm)"
            )
        else {
            throw NSError(
                domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URLの作成に失敗しました"])
        }

        // 保存先ディレクトリの作成
        try? FileManager.default.createDirectory(
            at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        // URLSessionを設定（リダイレクトを許可）
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 1
        let session = URLSession(configuration: config)

        // ダウンロード実行
        let (tempURL, response) = try await session.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw NSError(
                domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ダウンロードに失敗しました"])
        }

        try FileManager.default.moveItem(at: tempURL, to: destinationURL)

        downloadedVvms.insert(model.vvm)
    }
}

extension Array where Element == VoiceModel {
    func groupedByVvm() -> [String: [VoiceModel]] {
        Dictionary(grouping: self, by: { $0.vvm })
    }
}
