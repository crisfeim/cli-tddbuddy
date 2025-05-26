// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

import XCTest
import Core

class GeneratorTests: XCTestCase {
    func test_generateCode_deliversCodeOnClientSuccess() async throws {
        
        let client = ClientStub(stub: .success(anyGeneratedCode()))
        let sut = makeSUT(client: client)
        let (generated, _) = try await sut.generateCode(from: anySpecs())
        XCTAssertEqual(generated, anyGeneratedCode())
    }
    
    func test_generateCode_deliversErrorOnClientError() async throws {
        
        let client = ClientStub(stub: .failure(anyError()))
        let sut = makeSUT(client: client)
        do {
            let _ = try await sut.generateCode(from: anySpecs())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateCode_deliversErrorOnRunnerError() async throws {
        
        let runner = RunnerStub(stub: .failure(anyError()))
        let sut = makeSUT(runner: runner)
        do {
            let _ = try await sut.generateCode(from: anySpecs())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateCode_deliversOutputOnRunnerSuccess() async throws {
        
        let runner = RunnerStub(stub: .success(anyProcessOutput()))
        let sut = makeSUT(runner: runner)
        let (_, output) = try await sut.generateCode(from: anySpecs())
        
        anyProcessOutput() .* { expected in
            XCTAssertEqual(output.stderr, expected.stderr)
            XCTAssertEqual(output.stdout, expected.stdout)
            XCTAssertEqual(output.exitCode, expected.exitCode)
        }
    }

    func test_generatedCode_usesConcatenatedCodeAsRunnerInput() async throws {
        class RunnerSpy: Runner {
            var code: String?
            func run(_ code: String) throws -> Runner.ProcessOutput {
                self.code = code
                return ("", "", 0)
            }
        }
        
        let clientStub = ClientStub(stub: .success(anyGeneratedCode()))
        let runner = RunnerSpy()
        let sut = makeSUT(client: clientStub, runner: runner, concatenator: ++)
        _ = try await sut.generateCode(from: anySpecs())
        XCTAssertEqual(runner.code?.contains(anySpecs()), true)
        XCTAssertEqual(runner.code?.contains(anyGeneratedCode()), true)
    }
    
    func test_generateCode_sendsSpecsToClient() async throws {
        class ClientSpy: Client {
            var sentMessage: String?
            func send(systemPrompt: String, userMessage: String) async throws -> String {
                sentMessage = userMessage
                return ""
            }
        }
        
        let clientSpy = ClientSpy()
        let sut = makeSUT(client: clientSpy)
        _ = try await sut.generateCode(from: anySpecs())
        XCTAssertEqual(clientSpy.sentMessage, anySpecs())
    }
    
    func makeSUT(
        client: Client = ClientDummy(),
        runner: Runner = RunnerDummy(),
        concatenator: @escaping Concatenator = anyConcatenator()
    ) -> Generator {
        Generator(
            systemPrompt: "any system promt",
            client: client,
            runner: runner,
            concatenator: concatenator
        )
    }
}

// MARK: - Fakes
private extension GeneratorTests {
    
    struct RunnerDummy: Runner {
        func run(_ code: String) throws -> ProcessOutput {
            ("","",0)
        }
    }
    
    struct ClientStub: Client {
        let stub: Result<String, Error>
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            try stub.get()
        }
    }
    
    struct ClientDummy: Client {
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            ""
        }
    }
    struct RunnerStub: Runner {
        let stub: Result<ProcessOutput, Error>
        func run(_ code: String) throws -> ProcessOutput {
            try stub.get()
        }
    }
    
}

// MARK: - Factories
private extension GeneratorTests {
    func anyProcessOutput() -> Runner.ProcessOutput {
        ("", "", 0)
    }
    
    private func anyGeneratedCode() -> String {
        "any generated code"
    }
    
    private func anySpecs() -> String {
        "any specs"
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    static func anyConcatenator() -> Concatenator {
        { _,_ in "" }
    }
}

infix operator .*
@discardableResult
func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}
