// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class CoordinatorTests: XCTestCase {
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let sut = makeSUT(reader: reader)
        do {
            try await sut.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let sut = makeSUT(reader: reader)
        do {
            try await sut.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnClientError() async throws {
        let client = ClientStub(result: .failure(anyError()))
        let coordinatior = makeSUT(client: client)
        do {
            try await coordinatior.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnClientSuccess() async throws {
        let client = ClientStub(result: .success("any genereted code"))
        let coordinator = makeSUT(client: client)
        do {
            try await coordinator.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnRunnerError() async throws {
        let runner = RunnerStub(result: .failure(anyError()))
        let coordinator = makeSUT(runner: runner)
        do {
            try await coordinator.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversOutputOnRunnerSuccess() async throws {
        let runner = RunnerStub(result: .success(anyProcessOutput()))
        let coordinator = makeSUT(runner: runner)
        let result = try await coordinator.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
        
        let output = result.procesOutput
        anyProcessOutput() .* { expected in
            XCTAssertEqual(output.stderr, expected.stderr)
            XCTAssertEqual(output.stdout, expected.stdout)
            XCTAssertEqual(output.exitCode, expected.exitCode)
        }
    }
    
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
        
        let coordinator = makeSUT(reader: readerStub, client: clientStub, runner: runnerSpy)
        try await coordinator.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        XCTAssertEqual(runnerSpy.code, "\(anyGeneratedCode())\n\(anySpecs())")
    }
    
    
    func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
        let persistor = PersistorStub(result: .failure(anyError()))
        let sut = makeSUT(persistor: persistor)
        do {
            try await sut.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnPersistenceSuccess() async throws {
        let persistor = PersistorStub(result: .success(()))
        let sut = makeSUT(persistor: persistor)
        do {
            try await sut.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_sendsContentsOfReadFileToClient() async throws {
        class ClientSpy: Client {
            var userMessage: String?
            func send(systemPrompt: String, userMessage: String) async throws -> String {
                self.userMessage = userMessage
                return "any generated code"
            }
        }
        
        let reader = FileReaderStub(result: .success(anyString()))
        let clientSpy = ClientSpy()
        let sut = makeSUT(reader: reader, client: clientSpy)
        
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        XCTAssertEqual(clientSpy.userMessage, anyString())
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
        let iterator = Iterator()
        let failedProcessOutput = anyFailedProcessOutput()
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerStub = RunnerStub(result: .success(failedProcessOutput))
        let sut = makeSUT(client: clientStub, runner: runnerStub, iterator: iterator)
        try await sut.generateAndSaveCode(systemPrompt: anySystemPrompt(), specsFileURL: anyURL(), outputFileURL: anyURL(), maxIterationCount: 5)
        
        XCTAssertEqual(iterator.count, 5)
    }

    private func makeSUT(
        reader: FileReader = FileReaderDummy(),
        client: Client = ClientDummy(),
        runner: Runner = RunnerDummy(),
        persistor: Persistor = PersistorDummy(),
        iterator: Iterator = Iterator()
    ) -> Coordinator {
        Coordinator(
            reader: reader,
            client: client,
            runner: runner,
            persistor: persistor,
            iterator: iterator
        )
    }
    
    struct PersistorStub: Persistor {
        let result: Result<Void, Error>
        func persist(_ string: String, outputURL: URL) throws {
            try result.get()
        }
    }
    
    struct FileReaderStub: FileReader {
        let result: Result<String, Error>
        func read(_: URL) throws -> String {
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
    
    struct PersistorDummy: Persistor {
        func persist(_ string: String, outputURL: URL) throws {
        }
    }
    
    struct ClientDummy: Client {
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            ""
        }
    }
    
    struct RunnerDummy: Runner {
        func run(_ code: String) throws -> ProcessOutput {
            (stdout: "", stderr: "", exitCode: 0)
        }
    }
}

// MARK: - Helpers
private extension CoordinatorTests {
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    func anyGeneratedCode() -> String {
        "any generated code"
    }
    
    func anyString() -> String {
        "any string"
    }
    
    func anySystemPrompt() -> String {
        "any system prompt"
    }
    
    private func anySpecs() -> String {
        "any specs"
    }
    
    func anyProcessOutput() -> Runner.ProcessOutput {
        ("", "", 0)
    }
    
    private static var failedExitCode: Int { 1 }
    private func anyFailedProcessOutput() -> Runner.ProcessOutput {
        (stdout: "", stderr: "", exitCode: Self.failedExitCode)
    }
}
