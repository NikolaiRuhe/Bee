import XCTest
import Bee

final class BeePerformanceTests: XCTestCase {
    func testDictionaryLookupPerformance() async throws {
        let sut = try await BeeDictionary.shared

        measure {
            for testCase in Zeit.allCases {
                let results = sut.wordsMatching(testCase.letters).joined(separator: ", ")
                XCTAssertEqual(results, testCase.expected, file: testCase.file, line: testCase.line)
            }
        }
    }

    func testEagerAsyncDecompressionPerformance() {
        measureAsync {
            let sut = InputStream(url: Resources.dictionaryURL)!
                .asyncStream(chunkSize: 20480)
                .decompressEager()
            let count = try! await sut.reduce(0) { $0 + $1.count }
            XCTAssertEqual(count, 35_801_440)
        }
    }

    func testLazyAsyncDecompressionPerformance() {
        measureAsync {
            let sut = InputStream(url: Resources.dictionaryURL)!
                .asyncStream(chunkSize: 20480)
                .decompressLazy()
            let count = try! await sut.reduce(0) { $0 + $1.count }
            XCTAssertEqual(count, 35_801_440)
        }
    }

    func testSyncDecompressionPerformance() {
        measure {
            let sut = try! Data(contentsOf: Resources.dictionaryURL).decompressed()
            let count = sut.count
            XCTAssertEqual(count, 35_801_440)
        }
    }
}

extension XCTestCase {
    func measureAsync(_ block: @escaping () async -> Void) {
        measure {
            try! sync {
                await block()
            }
        }
    }
}

public func sync<Result>(_ body: @escaping () async throws -> Result) throws -> Result  {
    var result: Result?
    let setResult = { result = $0 }
    var error: Error?
    let setError = { error = $0 }
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        do {
            setResult(try await body())
        } catch {
            setError(error)
        }
        semaphore.signal()
    }
    semaphore.wait()
    if let error = error { throw error }
    return result!
}
