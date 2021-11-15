import Foundation

public enum Resources {
    public static let dictionaryURL = Bundle.module.url(forResource: "german", withExtension: "zlib")!
    public static let dictionaryData = try! Data(contentsOf: dictionaryURL).decompressed(algorithm: .zlib)

    internal static var directoryURL: URL {
        var url = URL(fileURLWithPath: #file)
        url.deleteLastPathComponent()
        url.appendPathComponent("Resources")
        return url
    }

    public static func createCompressedDictionary() throws {
        let url = directoryURL.appendingPathComponent("german.dic")
        let data = try Data(contentsOf: url)
        let compressed = try data.compressed(algorithm: .zlib)
        let targetURL = directoryURL.appendingPathComponent("german.zlib")
        try compressed.write(to: targetURL)
    }
}
