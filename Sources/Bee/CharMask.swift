import Foundation

public typealias CharMask = UInt64

public extension CharMask {
    static func mask(from string: String) -> CharMask {
        guard let data = string.data(using: .isoLatin1) else {
            fatalError("can't encode string \(string)")
        }
        return data.reduce(CharMask.zero) { $0 | Char(fromLatin1: $1).mask }
    }

    func isSubset(of mask: CharMask) -> Bool { (~mask & self) == .zero}
}


public struct Chars: Equatable, Sendable {
    let sortedElements: [Char]

    public init(_ chars: [Char]) {
        self.sortedElements = chars.sorted()
    }

    public init(_ data: Data) {
        self.init(data.map { Char(fromLatin1: $0) })
    }

    public init(_ data: Data, startingAt start: Int) {
        var pos = start
        var chars: [Char] = []
        while pos != data.endIndex {
            defer { pos += 1 }
            let char = Char(fromLatin1: data[pos])
            if char == .newline { break }
            chars.append(char)
        }
        self.init(chars)
    }

    public init(_ string: String) {
        guard let data = string.data(using: .isoLatin1) else {
            fatalError("can't encode string \(string)")
        }

        self.init(data)
    }

    var mask: CharMask {
        return sortedElements.reduce(CharMask.zero) { $0 | $1.mask }
    }

    public func isSubset(of other: Chars) -> Bool {

        var otherChars = other.sortedElements.makeIterator()
        var other = otherChars.next()

        for char in sortedElements {
            while let o = other, char > o {
                other = otherChars.next()
            }
            guard other == char else { return false }
            other = otherChars.next()
        }
        return true
    }
}
