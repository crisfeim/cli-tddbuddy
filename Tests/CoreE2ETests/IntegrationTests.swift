// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core
import tddbuddy

class IntegrationTests: XCTestCase {
    func test_adder_generation() async throws {
        let systemPrompt = """
            Imagine that you are a programmer and the user's responses are feedback from compiling your code in your development environment. Your responses are the code you write, and the user's responses represent the feedback, including any errors.
            
            Implement the SUT's code in Swift based on the provided specs (unit tests).
            
            Follow these strict guidelines:
            
            1. Provide ONLY runnable Swift code. No explanations, comments, or formatting (no code blocks, markdown, symbols, or text).
            2. DO NOT include unit tests or any test-related code.
            3. ALWAYS IMPORT ONLY Foundation. No other imports are allowed.
            4. DO NOT use access control keywords (`public`, `private`, `internal`) or control flow keywords in your constructs.
            
            If your code fails to compile, the user will provide the error output for you to make adjustments.
            """
        let reader = FileManager.default
        let client = LoggerDecorator(OllamaClient())
        let runner = LoggerDecorator(SwiftRunner())
        let persistor = LoggerDecorator(FilePersistor())
        let iterator = LoggerDecorator(Iterator())
        let sut = Coordinator(
            reader: reader,
            client: client,
            runner: runner,
            concatenator: (++),
            persistor: persistor,
            iterator: iterator
        )
        let adderSpecs = specsURL("adder.swift.txt")
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("adder.swift.txt")
        let output = try await sut.generateAndSaveCode(systemPrompt: systemPrompt, specsFileURL: adderSpecs, outputFileURL: tmpURL, maxIterationCount: 5)
        
        XCTAssertFalse(output.generatedCode.isEmpty)
        XCTAssertEqual(output.procesOutput.exitCode, 0)
    }
    
    func specsURL(_ filename: String) -> URL {
        inputFolder().appendingPathComponent(filename)
    }
    
    func testsResourceDirectory() -> URL {
        Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
    }
    
    func inputFolder() -> URL {
        testsResourceDirectory().appendingPathComponent("inputs")
    }
}
