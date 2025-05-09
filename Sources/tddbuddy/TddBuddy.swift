// main.swift
import Foundation
import ArgumentParser
import Core

@main
struct TDDBuddy: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "The path to the specs file.")
    var input: String

    @Option(name: .shortAndLong, help: "The path where the generated code will be saved.")
    var output: String

    @Option(name: .shortAndLong, help: "Maximum number of iterations (default is 5).")
    var iterations: Int = 5

    func run() async throws {
        let client = LoggerDecorator(OllamaClient())
        let runner = LoggerDecorator(SwiftRunner())
        let persistor = LoggerDecorator(FilePersistor())
        let iterator = LoggerDecorator(Iterator())
        let generator = LoggerDecorator(Generator(systemPrompt: TDDBuddy.systemPrompt, client: client, runner: runner))
        
        let coordinator = Coordinator(
            reader: FileManager.default,
            generator: generator,
            persistor: persistor,
            iterator: iterator
        )

        let inputURL = URL(fileURLWithPath: input)
        let outputURL = URL(fileURLWithPath: output)

        let result = try await coordinator.generateAndSaveCode(
            specsFileURL: inputURL,
            outputFileURL: outputURL,
            maxIterationCount: iterations
        )
        
        result.procesOutput.exitCode != 0
        ? Logger.info("❌ Code generated didn't meet the specs")
        : ()
        
    }
}

private extension TDDBuddy {
    static let systemPrompt = """
        Imagine that you are a programmer and the user's responses are feedback from compiling your code in your development environment. Your responses are the code you write, and the user's responses represent the feedback, including any errors.
        
        Implement the SUT's code in Swift based on the provided specs (unit tests).
        
        Follow these strict guidelines:
        
        1. Provide ONLY runnable Swift code. No explanations, comments, or formatting (no code blocks, markdown, symbols, or text).
        2. DO NOT include unit tests or any test-related code.
        3. ALWAYS IMPORT ONLY Foundation. No other imports are allowed.
        4. DO NOT use access control keywords (`public`, `private`, `internal`) or control flow keywords in your constructs.
        
        If your code fails to compile, the user will provide the error output for you to make adjustments.
        """
}
