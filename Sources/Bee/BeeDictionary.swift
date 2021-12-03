import Foundation

public actor BeeDictionary {
    let wordData: Data
    let entries: [Entry]

    public init(dictionaryData: Data = Resources.dictionaryData, maximumWordCount: Int = .max) throws {
        self.wordData = dictionaryData
        self.entries = wordData.parseWords(maximumCount: maximumWordCount)
    }

    public init(dictionaryData: Data = Resources.dictionaryData, chunkSize: Int = 20_000) async throws {
        self.wordData = dictionaryData
        self.entries = await dictionaryData.parseWords(chunkSize: chunkSize)
    }
}

public extension BeeDictionary {
    nonisolated var count: Int { entries.count }

    nonisolated func wordsMatching(_ string: String) -> [String] {
        return self[indicesMatching(string)]
            .filter { $0.uppercased().contains(string.first!) }
            .filter { $0.count >= 3 }
            .sorted(by: longestFirst)
    }

    nonisolated func indicesMatching(_ string: String) -> [Int] {
        let chars = Chars(string)
        let mask = chars.mask
        return indicesMatching(mask)
            .filter { self.chars(at: $0).isSubset(of: chars) }
    }

    nonisolated func indicesMatching(_ mask: CharMask) -> [Int] {
        entries.enumerated()
            .filter { $0.1.charMask.isSubset(of: mask) }
            .map { $0.0 }
    }

    nonisolated subscript(_ index: Int) -> String {
        let start = entries[index].position
        var endIndex = start
        while endIndex != wordData.endIndex {
            if Char(fromLatin1: wordData[endIndex]) == .newline { break }
            endIndex += 1
        }
        return String(data: wordData[start ..< endIndex], encoding: .isoLatin1)!
    }

    nonisolated subscript(_ indices: [Int]) -> [String] {
        indices.map { self[$0] }
    }
}

extension BeeDictionary {
    nonisolated func chars(at index: Int) -> Chars {
        Chars(wordData, startingAt: entries[index].position)
    }

    struct Entry {
        let position: Data.Index
        let charMask: CharMask
        init(position: Data.Index, charMask: CharMask) {
            self.position = position
            self.charMask = charMask
        }
    }

    actor Container<Wrapped> {
        private var _content: Wrapped? = nil
        private var factory: (() async throws -> Wrapped)?
        init(factory: @Sendable @escaping () async throws -> Wrapped) {
            self.factory = factory
        }
        var testDict: Wrapped {
            get async throws {
                if let content = _content { return content }
                let content = try await factory!()
                factory = nil
                _content = content
                return content
            }
        }
    }
    static let container = Container { try await BeeDictionary(chunkSize: 20_000) }
}

public extension BeeDictionary {
    static var shared: BeeDictionary {
        get async throws { try await container.testDict }
    }
}

extension Data {
    func parseWords(maximumCount: Int = .max) -> [BeeDictionary.Entry] {
        var entries: [BeeDictionary.Entry] = []

        var startOfLine = startIndex
        var charMask: CharMask = 0

        for cursor in indices {
            let charIndex = Char(fromLatin1: self[cursor])
            if charIndex != .newline {
                charMask |= charIndex.mask
                continue
            }

            if startOfLine != cursor {
                let entry = BeeDictionary.Entry(position: startOfLine, charMask: charMask)
                entries.append(entry)
                if entries.count == maximumCount { break }
            }

            startOfLine = cursor.advanced(by: 1)
            charMask = 0
        }

        return entries
    }

    func parseWords(chunkSize: Int) async -> [BeeDictionary.Entry] {
        await withTaskGroup(of: [BeeDictionary.Entry].self, returning: [BeeDictionary.Entry].self) { group in
            for chunk in alignedChunks(ofSize: chunkSize) {
                group.addTask { chunk.parseWords() }
            }
            return await group.reduce(into: []) { $0.append(contentsOf: $1) }
        }
    }

    func alignedChunks(ofSize size: Int) -> AnySequence<Data> {
        AnySequence(sequence(state: startIndex) { start in
            if start == endIndex { return nil }
            let end = clampedAndAdvancedToLineBoundary(start.advanced(by: size))
            let item = self[start..<end]
            start = end
            return item
        })
    }

    func clampedAndAdvancedToLineBoundary(_ index: Index) -> Index {
        var index = Swift.min(index, endIndex)
        while index != endIndex {
            if self[index] == 10 {
                return index.advanced(by: 1)
            }
            index += 1
        }
        return index
    }
}

func longestFirst(lhs: String, rhs: String) -> Bool {
    guard lhs.count == rhs.count else { return lhs.count > rhs.count }
    return lhs < rhs
}
