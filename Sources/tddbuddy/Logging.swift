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

// MARK: - Client
extension LoggerDecorator: Client where T: Client {
    public func send(systemPrompt: String, userMessage: String) async throws -> String {
        try await decoratee.send(systemPrompt: systemPrompt, userMessage: userMessage)
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


// MARK: - Iterator
extension LoggerDecorator: Coordinator.Iterator where T: Coordinator.Iterator {
    public var count: Int {decoratee.count}
    public func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws {
        let action: () async throws -> Void = { [decoratee] in
            Logger.info("🔄 Iterating \(decoratee.count) / \(n) times...")
            try await action()
        }
        try await decoratee.iterate(nTimes: n, until: condition, action: action)
    }
}
