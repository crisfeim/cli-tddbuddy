// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
import Foundation
import Core

enum Logger {
    static func log(_ message: String) {
        print(message)
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
        Logger.log("🟡 [Client] Sending specs")
        let response = try await decoratee.send(systemPrompt: systemPrompt, userMessage: userMessage)
        Logger.log("🟢 [Client] Received Response")
        return response
    }
}

// MARK: - Runner
extension LoggerDecorator: Runner where T: Runner {
    public func run(_ code: String) throws -> ProcessOutput {
        Logger.log("🟡 [Runner] Running code")
        let result = try decoratee.run(code)
        Logger.log("🟢 [Runner] Code run")

        return result
    }
}

// MARK: - Persistor
extension LoggerDecorator: Persistor where T: Persistor {
    public func persist(_ string: String, outputURL: URL) throws {
        Logger.log("🟡 [Persistor] Saving to \(outputURL.path):")
        try decoratee.persist(string, outputURL: outputURL)
        Logger.log("🟢 [Persistor] Save successful")
    }
}

// MARK: - FileReader
extension LoggerDecorator: FileReader where T: FileReader {
    public func read(_ url: URL) throws -> String {
        Logger.log("🟡 [FileReader] Reading from: \(url.path)")
        let contents = try decoratee.read(url)
        Logger.log("🟢 [FileReader] Contents read")

        return contents
    }
}

// MARK: - Generator
extension LoggerDecorator: Coordinator.Generator where T: Coordinator.Generator {
    public func generateCode(from specs: String) async throws -> Output {
        Logger.log("🟡 [Generator] Generating code from specs")
        let output = try await decoratee.generateCode(from: specs)
        Logger.log("🟢 [Generator] Code Generated with exit code: \(output.procesOutput.exitCode)")
        Logger.log("🔚 Exit Code: \(output.procesOutput.exitCode)")

        return output
    }
}
