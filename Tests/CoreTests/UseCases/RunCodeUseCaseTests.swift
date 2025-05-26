// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

extension CoordinatorTests {
  
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
        let runner = RunnerStub(result: .success(anySuccessProcessOutput()))
        let sut = makeSUT(runner: runner)
        let result = try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        let output = result.procesOutput
        anySuccessProcessOutput() .* { expected in
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
}

infix operator .*: AdditionPrecedence

@discardableResult
private func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
  var copy = lhs
  rhs(&copy)
  return copy
}
