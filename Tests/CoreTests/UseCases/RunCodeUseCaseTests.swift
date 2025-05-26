// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class RunCodeUseCaseTests: XCTestCase {
  
    func test_generateAndSaveCode_deliversErrorOnRunnerError() async throws {
        let runner = RunnerStub(result: .failure(anyError()))
        let sut = makeSUT(runner: runner)
        await XCTAssertThrowsErrorAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversOutputOnRunnerSuccess() async throws {
        let runner = RunnerStub(result: .success(anyProcessOutput()))
        let sut = makeSUT(runner: runner)
        let result = try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        let output = result.procesOutput
        anyProcessOutput() .* { expected in
            XCTAssertEqual(output.stderr, expected.stderr)
            XCTAssertEqual(output.stdout, expected.stdout)
            XCTAssertEqual(output.exitCode, expected.exitCode)
        }
    }
    
    
    private func makeSUT(runner: Runner) -> Coordinator {
        Coordinator(
            reader: FileReaderDummy(),
            client: ClientDummy(),
            runner: runner,
            persistor: PersistorDummy(),
            iterator: Iterator()
        )
    }
    
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    func anySystemPrompt() -> String {
        "any system prompt"
    }
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyGeneratedCode() -> String {
        "any generated code"
    }
    
    private func anySpecs() -> String {
        "any specs"
    }
    
    func anyProcessOutput() -> Runner.ProcessOutput {
        ("", "", 0)
    }
}
