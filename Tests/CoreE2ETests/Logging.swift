// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
import Foundation
import Core

final class LoggerDecorator<T> {
    let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
}

// MARK: - Client
extension LoggerDecorator: Client where T: Client {
    func send(systemPrompt: String, userMessage: String) async throws -> String {
        print("🟡 [Client] Sending:")
        print("System Prompt:\n\(systemPrompt)")
        print("User Message:\n\(userMessage)")

        let response = try await decoratee.send(systemPrompt: systemPrompt, userMessage: userMessage)

        print("🟢 [Client] Response:")
        print(response)

        return response
    }
}

// MARK: - Runner
extension LoggerDecorator: Runner where T: Runner {
    func run(_ code: String) throws -> ProcessOutput {
        print("🟡 [Runner] Running code:")
        print(code)

        let result = try decoratee.run(code)

        print("🟢 [Runner] Output:")
        print("stdout: \(result.stdout)")
        print("stderr: \(result.stderr)")
        print("exitCode: \(result.exitCode)")

        return result
    }
}

// MARK: - Persistor
extension LoggerDecorator: Persistor where T: Persistor {
    func persist(_ string: String, outputURL: URL) throws {
        print("🟡 [Persistor] Saving to \(outputURL.path):")
        print(string)

        try decoratee.persist(string, outputURL: outputURL)

        print("🟢 [Persistor] Save successful")
    }
}

// MARK: - FileReader
extension LoggerDecorator: FileReader where T: FileReader {
    func read(_ url: URL) throws -> String {
        print("🟡 [FileReader] Reading from: \(url.path)")

        let contents = try decoratee.read(url)

        print("🟢 [FileReader] Contents read:")
        print(contents)

        return contents
    }
}

// MARK: - Generator
extension LoggerDecorator: Coordinator.Generator where T: Coordinator.Generator {
    func generateCode(from specs: String) async throws -> Output {
        print("🟡 [Generator] Generating code from specs:")
        print(specs)

        let output = try await decoratee.generateCode(from: specs)

        print("🟢 [Generator] Generated Code:")
        print(output.generatedCode)
        print("🟢 [Generator] Stdout:\n\(output.output.stdout)")
        print("🟠 [Generator] Stderr:\n\(output.output.stderr)")
        print("🔚 Exit Code: \(output.output.exitCode)")

        return output
    }
}
