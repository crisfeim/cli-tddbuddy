// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
import Foundation
import Core
import os

let logger = os.Logger(subsystem: "me.crisfe.tddbuddy.cli", category: "core")

enum Logger {
    static func info(_ message: String) {
        print(message)
        logger.info("\(message, privacy: .public)")
    }
}

public final class LoggerDecorator<T> {
    let decoratee: T
    
    public init(_ decoratee: T) {
        self.decoratee = decoratee
    }
}


// MARK: - Runner
extension LoggerDecorator: Runner where T: Runner {
    public func run(_ code: String) throws -> ProcessOutput {
        try decoratee.run(code)
    }
}

// MARK: - Persistor
extension LoggerDecorator: Persistor where T: Persistor {
    public func persist(_ string: String, outputURL: URL) throws {
        try decoratee.persist(string, outputURL: outputURL)
        Logger.info("📍 Output saved to \(outputURL.path):")
    }
}

// MARK: - FileReader
extension LoggerDecorator: FileReader where T: FileReader {
    public func read(_ url: URL) throws -> String {
        let contents = try decoratee.read(url)
        return contents
    }
}
