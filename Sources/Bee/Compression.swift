import Foundation
import Compression

public extension Data {
    func compressed(algorithm: Algorithm = .zlib) throws -> Data {
        try filtered(operation: .compress, algorithm: algorithm)
    }

    func decompressed(algorithm: Algorithm = .zlib) throws -> Data {
        try filtered(operation: .decompress, algorithm: algorithm)
    }
}

fileprivate extension Data {
    func filtered(operation: FilterOperation, algorithm: Algorithm) throws -> Data {
        var result = Data()
        let outputFilter = try OutputFilter(operation, using: algorithm) {
            if let data = $0 { result.append(data) }
        }
        for chunk in chunks(ofSize: 1024) {
            try outputFilter.write(chunk)
        }
        try outputFilter.finalize()
        return result
    }

    func chunks(ofSize size: Int) -> AnySequence<Data> {
        AnySequence(sequence(state: startIndex) { start in
            if start == endIndex { return nil }
            let end = Swift.min(start.advanced(by: size), endIndex)
            defer { start = end }
            return self[start..<end]
        })
    }
}
