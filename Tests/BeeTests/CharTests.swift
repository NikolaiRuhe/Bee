import XCTest
import Bee

final class CharTests: XCTestCase {

    func testCharsSubsetEqual() throws {
        let sut1 = Chars("ABC")
        let sut2 = Chars("abc")
        XCTAssertTrue(sut1.isSubset(of: sut2))
        XCTAssertTrue(sut2.isSubset(of: sut1))
    }

    func testCharsSubset() throws {
        let sut1 = Chars("a")
        let sut2 = Chars("ab")
        XCTAssertTrue(sut1.isSubset(of: sut2))
        XCTAssertFalse(sut2.isSubset(of: sut1))
    }

    func testCharsSubsetRepeated() throws {
        let sut1 = Chars("aa")
        let sut2 = Chars("aab")
        XCTAssertTrue(sut1.isSubset(of: sut2))
        XCTAssertFalse(sut2.isSubset(of: sut1))
    }

    func testCharsSubsetRepeated2() throws {
        let sut1 = Chars("aabbbc")
        let sut2 = Chars("aaaaabbbc")
        XCTAssertTrue(sut1.isSubset(of: sut2))
        XCTAssertFalse(sut2.isSubset(of: sut1))
    }

    func testCharsSubsetRepeated3() throws {
        let sut1 = Chars("aabbbbc")
        let sut2 = Chars("aaaaabbbc")
        XCTAssertFalse(sut1.isSubset(of: sut2))
        XCTAssertFalse(sut2.isSubset(of: sut1))
    }

    func testCharMaskSubset() throws {
        let sut = 0b0010 as CharMask
        let mask = 0b0011 as CharMask
        XCTAssertTrue(sut.isSubset(of: mask))
        XCTAssertFalse(mask.isSubset(of: sut))
    }

    func test_createCompressedDictionary() throws {
        try XCTSkipIf(true, "comment to execute")
        try Resources.createCompressedDictionary()
    }
}

