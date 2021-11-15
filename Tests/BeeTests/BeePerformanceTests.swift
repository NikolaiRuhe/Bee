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
}
