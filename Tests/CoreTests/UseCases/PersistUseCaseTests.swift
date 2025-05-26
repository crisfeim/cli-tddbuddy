// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class PersistUseCaseTests: XCTestCase {
    
    func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
        let persistor = PersistorStub(result: .failure(anyError()))
        let sut = makeSUT(persistor: persistor)
        await XCTAssertThrowsErrorAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnPersistenceSuccess() async throws {
        let persistor = PersistorStub(result: .success(()))
        let sut = makeSUT(persistor: persistor)
        await XCTAssertNoThrowAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }

    private func makeSUT(persistor: Persistor) -> Coordinator {
        Coordinator(
            reader: FileReaderDummy(),
            client: ClientDummy(),
            runner: RunnerDummy(),
            persistor: persistor,
            iterator: Iterator()
        )
    }
    
    struct PersistorStub: Persistor {
        let result: Result<Void, Error>
        func persist(_ string: String, outputURL: URL) throws {
            try result.get()
        }
    }
    
    struct ClientStub: Client {
        let result: Result<String, Error>
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            try result.get()
        }
    }
    
    struct RunnerStub: Runner {
        let result: Result<ProcessOutput, Error>
        func run(_ code: String) throws -> ProcessOutput {
            try result.get()
        }
    }
    
    struct FileReaderDummy: FileReader {
        func read(_ url: URL) throws -> String {
            ""
        }
    }
   
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anySpecs() -> String {
        "any specs"
    }
    
    func anyString() -> String {
        "any string"
    }
    
    
    func anySystemPrompt() -> String {
        "any system prompt"
    }
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    func anyGeneratedCode() -> String {
        "any generated code"
    }
    
    static let failedExitCode = 0
    private func anyFailedProcessOutput() -> Runner.ProcessOutput {
        (stdout: "", stderr: "", exitCode: Self.failedExitCode)
    }
}
