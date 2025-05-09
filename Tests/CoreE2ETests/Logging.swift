// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
import Foundation
import Core

enum Logger {
    static func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

final class LoggerDecorator<T> {
    let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
}

// MARK: - Client
extension LoggerDecorator: Client where T: Client {
    func send(systemPrompt: String, userMessage: String) async throws -> String {
        Logger.log("🟡 [Client] Sending:")
        Logger.log("System Prompt:\n\(systemPrompt)")
        Logger.log("User Message:\n\(userMessage)")

        let response = try await decoratee.send(systemPrompt: systemPrompt, userMessage: userMessage)

        Logger.log("🟢 [Client] Response:")
        Logger.log(response)

        return response
    }
}

// MARK: - Runner
extension LoggerDecorator: Runner where T: Runner {
    func run(_ code: String) throws -> ProcessOutput {
        Logger.log("🟡 [Runner] Running code:")
        Logger.log(code)

        let result = try decoratee.run(code)

        Logger.log("🟢 [Runner] Output:")
        Logger.log("stdout: \(result.stdout)")
        Logger.log("stderr: \(result.stderr)")
        Logger.log("exitCode: \(result.exitCode)")

        return result
    }
}

// MARK: - Persistor
extension LoggerDecorator: Persistor where T: Persistor {
    func persist(_ string: String, outputURL: URL) throws {
        Logger.log("🟡 [Persistor] Saving to \(outputURL.path):")
        Logger.log(string)

        try decoratee.persist(string, outputURL: outputURL)

        Logger.log("🟢 [Persistor] Save successful")
    }
}

// MARK: - FileReader
extension LoggerDecorator: FileReader where T: FileReader {
    func read(_ url: URL) throws -> String {
        Logger.log("🟡 [FileReader] Reading from: \(url.path)")

        let contents = try decoratee.read(url)

        Logger.log("🟢 [FileReader] Contents read:")
        Logger.log(contents)

        return contents
    }
}

// MARK: - Generator
extension LoggerDecorator: Coordinator.Generator where T: Coordinator.Generator {
    func generateCode(from specs: String) async throws -> Output {
        Logger.log("🟡 [Generator] Generating code from specs:")
        Logger.log(specs)

        let output = try await decoratee.generateCode(from: specs)

        Logger.log("🟢 [Generator] Generated Code:")
        Logger.log(output.generatedCode)
        Logger.log("🟢 [Generator] Stdout:\n\(output.procesOutput.stdout)")
        Logger.log("🟠 [Generator] Stderr:\n\(output.procesOutput.stderr)")
        Logger.log("🔚 Exit Code: \(output.procesOutput.exitCode)")

        return output
    }
}
