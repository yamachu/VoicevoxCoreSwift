import DataCompression
import SwiftUI
import Tarscape

struct DictionaryDownloaderView: View {
    @EnvironmentObject private var voicevoxEnvironmentObject: VoicevoxEnvironmentObject

    @State private var isDownloading = false
    @State private var errorMessage: String?

    public var body: some View {
        VStack {
            Button(action: downloadAndExtractDictionary) {
                HStack {
                    if isDownloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    Text(downloadButtonText)
                }
            }
            .disabled(isDownloading || voicevoxEnvironmentObject.isDictionaryInstalled)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }.onAppear {
            checkDictionaryExists()
        }
    }

    init() {
    }

    private var downloadButtonText: String {
        if voicevoxEnvironmentObject.isDictionaryInstalled {
            return "辞書ファイルインストール済み"
        } else if isDownloading {
            return "ダウンロード中..."
        } else {
            return "辞書をダウンロード"
        }
    }

    private func checkDictionaryExists() {
        let dictionaryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(dictionaryExtractPath)
        voicevoxEnvironmentObject.isDictionaryInstalled = FileManager.default.fileExists(
            atPath: dictionaryPath?.path ?? "")
    }

    private func downloadAndExtractDictionary() {
        isDownloading = true
        errorMessage = nil

        guard
            let url = URL(
                string:
                    "https://jaist.dl.sourceforge.net/project/open-jtalk/Dictionary/open_jtalk_dic-1.11/open_jtalk_dic_utf_8-1.11.tar.gz"
            )
        else {
            isDownloading = false
            return
        }

        guard
            let sharedContainer = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            )
            .first
        else {
            errorMessage = "共有ディレクトリの取得に失敗しました"
            isDownloading = false
            return
        }

        let destinationURL = sharedContainer.appendingPathComponent(
            _dictionaryRoot, isDirectory: true)

        try? FileManager.default.createDirectory(
            at: destinationURL, withIntermediateDirectories: true)

        let downloadTask = URLSession.shared.downloadTask(with: url) {
            tempFileUrl, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "ダウンロードエラー: \(error.localizedDescription)"
                    self.isDownloading = false
                    return
                }

                guard let tempFileUrl = tempFileUrl else {
                    self.errorMessage = "ダウンロードに失敗しました"
                    self.isDownloading = false
                    return
                }

                do {
                    let decompressedData = try Data(contentsOf: tempFileUrl).gunzip()
                    let tempTarPath = FileManager.default.temporaryDirectory.appendingPathComponent(
                        "dictionary.tar")
                    try decompressedData?.write(to: tempTarPath)
                    try FileManager.default.extractTar(
                        at: tempTarPath.standardizedFileURL, to: destinationURL.standardizedFileURL)
                    try FileManager.default.removeItem(at: tempTarPath)
                    self.errorMessage = nil
                    voicevoxEnvironmentObject.isDictionaryInstalled = true
                } catch {
                    self.errorMessage = "解凍・展開エラー: \(error.localizedDescription)"
                }

                self.isDownloading = false
            }
        }

        downloadTask.resume()
    }
}
