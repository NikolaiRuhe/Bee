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
        for chunk in chunks(ofSize: 20480) {
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

    func splitAtLastLineBoundary() -> (Data, Data)? {
        for index in indices.reversed() {
            if self[index] != 10 { continue }
            let line = self[...index]
            let rest = self[index.advanced(by: 1)...]
            return (line, rest)
        }
        return nil
    }
}

public enum StreamError: Error { case readFailure }

extension InputStream {
    public func asyncStream(chunkSize: Int) -> AsyncThrowingStream<Data, Error> {
        return AsyncThrowingStream { continuation in
            do {
                open()
                while true {
                    if let chunk = try read(maximumBytes: chunkSize) {
                        continuation.yield(chunk)
                    } else {
                        close()
                        continuation.finish()
                    }
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    fileprivate func read(maximumBytes: Int) throws -> Data? {
        var result = Data(count: maximumBytes)
        let count = result.withUnsafeMutableBytes {
            return read($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: maximumBytes)
        }
        guard count > 0 else {
            if count < 0 { throw streamError ?? StreamError.readFailure }
            return nil
        }
        return count == maximumBytes ? result : result.prefix(count)
    }
}

extension AsyncSequence where Element == Data {
    public func decompressLazy(algorithm: Algorithm = .zlib) -> AsyncThrowingStream<Data, Error> {
        var buffer = Data()
        var isDone = false
        // try! because we're assuming OutputFilter.init will never fail if passed valid arguments.
        let outputFilter = try! OutputFilter(.decompress, using: algorithm) { decompressed in
            if let decompressed = decompressed {
                // We have to copy data here in order to repair value semantics.
                // OutputFilter is obviously returning an NSData with no-copy semantics.
                buffer.append(decompressed)
            }
        }

        var iterator = self.makeAsyncIterator()
        return AsyncThrowingStream<Data, Error>(unfolding: {
            while true {
                guard let compressed = try await iterator.next() else {
                    // Input sequence is exhausted → finalize decompression stream
                    if !isDone {
                        try outputFilter.finalize()
                        isDone = true
                    }
                    break
                }
                try outputFilter.write(compressed)
                if !buffer.isEmpty {
                    break
                }
            }
            defer {
                buffer.removeAll()
            }
            // buffer can only be empty here if the input sequence is exhausted.
            return buffer.isEmpty ? nil : buffer
        })
    }
}

/// - TODO: This should be `where Element == Data, Self: Sendable` (we think), but that breaks some
///   tests that call this on `AsyncThrowingStream`.
extension AsyncSequence where Element == Data {
    public func decompressEager(algorithm: Algorithm = .zlib) -> AsyncThrowingStream<Data, Error> {
        return AsyncThrowingStream<Data, Error> { continuation in
            Task {
                do {
                    let outputFilter = try OutputFilter(.decompress, using: algorithm) {
                        if let data = $0 {
                            // We have to copy data here in order to repair value semantics.
                            // OutputFilter is obviously returning an NSData with no-copy semantics.
                            continuation.yield(Data(data))
                        }
                    }
                    for try await chunk in self {
                        try outputFilter.write(chunk)
                    }
                    try outputFilter.finalize()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

extension AsyncSequence where Element == Data {
    public func alignToLineBoundary() -> AsyncThrowingStream<Data, Error> {
        var input = self.makeAsyncIterator()
        var currentData: Data? = nil
        return AsyncThrowingStream<Data, Error> {
            while true {
                guard let data = try await input.next() else {
                    defer { currentData = nil }
                    return currentData
                }
                guard let (line, rest) = data.splitAtLastLineBoundary() else {
                    if let previousData = currentData {
                        currentData = previousData + data
                    } else {
                        currentData = data
                    }
                    continue
                }
                assert(line.last! == 10)
                defer { currentData = rest.isEmpty ? nil : rest }
                if let currentData = currentData {
                    return currentData + line
                } else {
                    return line
                }
            }
        }
    }
}
