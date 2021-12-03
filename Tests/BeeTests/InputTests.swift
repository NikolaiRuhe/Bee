import XCTest
import Bee

final class InputTests: XCTestCase {
    func testAsyncStream() async throws {
        let sut = InputStream(url: Resources.dictionaryURL)!
            .asyncStream(chunkSize: 2048)

        let count = try await sut.reduce(0) { $0 + $1.count }
        XCTAssertEqual(count, 6_689_096)
    }

    func testDecompressingAsyncStream() async throws {
        let sut = InputStream(url: Resources.dictionaryURL)!
            .asyncStream(chunkSize: 2048)
            .decompressEager(algorithm: .zlib)

        let count = try await sut.reduce(0) { $0 + $1.count }
        XCTAssertEqual(count, 35_801_440)
    }

    func testAlignBoundaryAsyncStream() async throws {
        let sut = InputStream(url: Resources.dictionaryURL)!
            .asyncStream(chunkSize: 2048)
            .decompressEager(algorithm: .zlib)
            .alignToLineBoundary()

        for try await chunk in sut {
            XCTAssertEqual(chunk.last!, 10)
        }
    }
}
