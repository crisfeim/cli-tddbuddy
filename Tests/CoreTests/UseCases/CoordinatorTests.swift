// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class CoordinatorTests: XCTestCase {
    
    func test_generateAndSaveCode_deliversErrorOnClientError() async throws {
        let client = ClientStub(result: .failure(anyError()))
        let coordinatior = makeSUT(client: client)
        
        await XCTAssertThrowsErrorAsync(
            try await coordinatior.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnClientSuccess() async throws {
        let client = ClientStub(result: .success("any genereted code"))
        let sut = makeSUT(client: client)
        await XCTAssertNoThrowAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
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
        
        let sut = makeSUT(reader: readerStub, client: clientStub, runner: runnerSpy)
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL()
        )
        
        XCTAssertEqual(runnerSpy.code, "\(anyGeneratedCode())\n\(anySpecs())")
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
    

    
    struct ClientStub: Client {
        let result: Result<String, Error>
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            try result.get()
        }
    }
    
    struct FileReaderDummy: FileReader {
        func read(_ url: URL) throws -> String {
            ""
        }
    }
}


struct RunnerStub: Runner {
    let result: Result<ProcessOutput, Error>
    func run(_ code: String) throws -> ProcessOutput {
        try result.get()
    }
}


struct FileReaderStub: FileReader {
    let result: Result<String, Error>
    func read(_: URL) throws -> String {
        try result.get()
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

struct FileReaderDummy: FileReader {
    func read(_ url: URL) throws -> String {
        ""
    }
}

func XCTAssertNoThrowAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "Expected no error, but error was thrown",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTFail(message(), file: file, line: line)
    }
}

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown, but no error was thrown", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}

// MARK: - Helpers
extension CoordinatorTests {
    
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
    
    func anySpecs() -> String {
        "any specs"
    }
    
    func anyProcessOutput() -> Runner.ProcessOutput {
        ("", "", 0)
    }
    
    private static var failedExitCode: Int { 1 }
    func anyFailedProcessOutput() -> Runner.ProcessOutput {
        (stdout: "", stderr: "", exitCode: Self.failedExitCode)
    }
}
