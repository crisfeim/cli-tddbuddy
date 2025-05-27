// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class CoordinatorTests: XCTestCase {    
    
    func test_generateAndSaveCode_usesConcatenatedCodeAsRunnerInputInTheRightOrder() async throws {
        class RunnerSpy: Runner {
            var code: String?
            func run(_ code: String) throws -> Runner.ProcessOutput {
                self.code = code
                return ("", "", 0)
            }
        }
        
        let readerStub = FileReaderStub(result: .success(anySpecs()))
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerSpy = RunnerSpy()
        
        let sut = makeSUT(reader: readerStub, client: clientStub, runner: runnerSpy)
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        XCTAssertEqual(runnerSpy.code, "\(anyGeneratedCode())\n\(anySpecs())")
    }
   
    func test_generateAndSaveCode_sendsContentsOfReadFileToClient() async throws {
        let reader = FileReaderStub(result: .success(anyString()))
        let clientSpy = ClientSpy()
        let sut = makeSUT(reader: reader, client: clientSpy)
        
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        let expectedMessages = [
            ["role": "system", "content": anySystemPrompt()],
            ["role": "user", "content": anyString()]
        ]
        XCTAssertEqual(clientSpy.messages, [expectedMessages])
    }
    
    func test_generateAndSaveCode_persistsGeneratedCode() async throws {
        class PersistorSpy: Persistor {
            var persistedString: String?
            func persist(_ string: String, outputURL: URL) throws {
                persistedString = string
            }
        }
        
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let persistorSpy = PersistorSpy()
        
        let sut = makeSUT(client: clientStub, persistor: persistorSpy)
        
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        XCTAssertEqual(persistorSpy.persistedString, anyGeneratedCode())
    }
    
    func test_generateAndSaveCode_retriesUntilMaxIterationWhenProcessFails() async throws {
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerStub = RunnerStubResults(results: [
            anyFailedProcessOutput(),
            anyFailedProcessOutput(),
            anyFailedProcessOutput()
        ])
        
        let sut = makeSUT(client: clientStub, runner: runnerStub)
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL(),
            maxIterationCount: 3
        )
        
        XCTAssertEqual(runnerStub.results.count, 0)
    }
    
    func test_generateAndSaveCode_retiresUntilSucessWhenProcessSucceedsAfterNRetries() async throws {
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerStub = RunnerStubResults(results: [
            anyFailedProcessOutput(),
            anyFailedProcessOutput(),
            anyFailedProcessOutput(),
            anySuccessProcessOutput()
        ])

       try await makeSUT(client: clientStub, runner: runnerStub).generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL(),
            maxIterationCount: 5
        ) .* {
            XCTAssertEqual($0.generatedCode, anyGeneratedCode())
            XCTAssertEqual($0.procesOutput.stderr, anySuccessProcessOutput().stderr)
            XCTAssertEqual($0.procesOutput.stdout, anySuccessProcessOutput().stdout)
            XCTAssertEqual($0.procesOutput.exitCode, anySuccessProcessOutput().exitCode)
        }
        
        XCTAssertEqual(runnerStub.results.count, 0)
    }

    
    func test_generateAndSaveCode_buildsMessagesWithPreviousFeedbackWhenIterationFails() async throws {
        let reader = FileReaderStub(result: .success(anySpecs()))
        let client = ClientSpy()
        let runner = RunnerStub(result: .success(anyFailedProcessOutput()))
        let sut = makeSUT(reader: reader, client: client, runner: runner)
        
        let _ = try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL(),
            maxIterationCount: 2
        )
        
        let expectedMessages = [
            ["role": "system", "content": anySystemPrompt()],
            ["role": "user", "content": anySpecs()],
            ["role": "assistant", "content": "failed attempt.\ncode:\(anyGeneratedCode())\nerror:\(anyFailedProcessOutput().stderr)"]
        ]
        
        XCTAssertEqual(client.messages.last?.normalized(), expectedMessages.normalized())
        
    }
    private func makeSUT(
        reader: FileReader = FileReaderDummy(),
        client: Client = ClientDummy(),
        runner: Runner = RunnerDummy(),
        persistor: Persistor = PersistorDummy()
    ) -> Coordinator {
        Coordinator(
            reader: reader,
            client: client,
            runner: runner,
            persistor: persistor
        )
    }
}

private extension [[String: String]] {
    func normalized() -> [NSDictionary] {
        map { $0 as NSDictionary }
    }
}
