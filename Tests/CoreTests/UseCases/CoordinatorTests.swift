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
        class ClientSpy: Client {
            var messages = [Message]()
            func send(messages: [Message]) async throws -> String {
                self.messages = messages
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
        
        let expectedMessages = [
            ["role": "system", "content": anySystemPrompt()],
            ["role": "user", "content": anyString()]
        ]
        XCTAssertEqual(clientSpy.messages, expectedMessages)
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
        
        class IteratorSpy: Iterator {
            var currentIteration = 0
            override func iterate<T>(nTimes n: Int, until condition: (T) -> Bool, action: () async throws -> T) async throws -> T {
                return try await super.iterate(nTimes: n, until: condition, action: {
                    currentIteration += 1
                    return try await action()
                })
            }
        }
        let iterator = IteratorSpy()
        let failedProcessOutput = anyFailedProcessOutput()
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerStub = RunnerStub(result: .success(failedProcessOutput))
        let sut = makeSUT(client: clientStub, runner: runnerStub, iterator: iterator)
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL(),
            maxIterationCount: 5
        )
        
        XCTAssertEqual(iterator.currentIteration, 5)
    }
    
    func test_generateAndSaveCode_retiresUntilSucessWhenProcessSucceedsAfterNRetries() async throws {
        class IteratorSpy: Iterator {
            var currentIteration = 0
            override func iterate<T>(nTimes n: Int, until condition: (T) -> Bool, action: () async throws -> T) async throws -> T {
                try await super.iterate(nTimes: n, until: condition, action: {
                    currentIteration += 1
                    return try await action()
                })
            }
        }
        
        class RunnerStub: Runner {
            var results = [ProcessOutput]()
            
            init(results: [ProcessOutput]) {
                self.results = results
            }
            
            func run(_ code: String) throws -> ProcessOutput {
                results.removeFirst()
            }
        }
        
        let iterator = IteratorSpy()
        let clientStub = ClientStub(result: .success(anyGeneratedCode()))
        let runnerStub = RunnerStub(results: [
            anyFailedProcessOutput(),
            anyFailedProcessOutput(),
            anyFailedProcessOutput(),
            anySuccessProcessOutput()
        ])
        
        let sut = makeSUT(client: clientStub, runner: runnerStub, iterator: iterator)
        try await sut.generateAndSaveCode(
            systemPrompt: anySystemPrompt(),
            specsFileURL: anyURL(),
            outputFileURL: anyURL(),
            maxIterationCount: 5
        )
        
        XCTAssertEqual(iterator.currentIteration, 4)
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
}

