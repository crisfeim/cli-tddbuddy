// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

import XCTest
import Core

class GeneratorTests: XCTestCase {
    func test_generateCode_deliversCodeOnClientSuccess() async throws {
        
        let client = ClientStub(stub: .success(anyGeneratedCode()))
        let generator = Generator(client: client, runner: RunnerDummy(), concatenator: ++)
        let (generated, _) = try await generator.generateCode(from: anySpecs())
        XCTAssertEqual(generated, anyGeneratedCode())
    }
    
    func test_generateCode_deliversErrorOnClientError() async throws {
        
        let client = ClientStub(stub: .failure(anyError()))
        let generator = Generator(client: client, runner: RunnerDummy(), concatenator: ++)
        do {
            let _ = try await generator.generateCode(from: anySpecs())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateCode_deliversErrorOnRunnerError() async throws {
        
        let runner = RunnerStub(stub: .failure(anyError()))
        let generator = Generator(client: ClientDummy(), runner: runner, concatenator: ++)
        do {
            let _ = try await generator.generateCode(from: anySpecs())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateCode_deliversOutputOnRunnerSuccess() async throws {
        
        let runner = RunnerStub(stub: .success(anyProcessOutput()))
        let generator = Generator(client: ClientDummy(), runner: runner, concatenator: ++)
        let (_, output) = try await generator.generateCode(from: anySpecs())
        
        anyProcessOutput() .* { expected in
            XCTAssertEqual(output.stderr, expected.stderr)
            XCTAssertEqual(output.stdout, expected.stdout)
            XCTAssertEqual(output.exitCode, expected.exitCode)
        }
    }

    func test_generatedCode_usesConcatenatedCodeAsRunnerInput() async throws {
        class RunnerSpy: Runner {
            var code: String?
            func run(_ code: String) throws -> Runner.Output {
                self.code = code
                return ("", "", 0)
            }
        }
        
        let clientStub = ClientStub(stub: .success(anyGeneratedCode()))
        let runner = RunnerSpy()
        let generator = makeSUT(client: clientStub, runner: runner, concatenator: ++)
        _ = try await generator.generateCode(from: anySpecs())
        XCTAssertEqual(runner.code?.contains(anySpecs()), true)
        XCTAssertEqual(runner.code?.contains(anyGeneratedCode()), true)
    }
    
    func makeSUT(
        client: Client = ClientDummy(),
        runner: Runner = RunnerDummy(),
        concatenator: @escaping Generator.Concatenator = (++)
    ) -> Generator {
        Generator(
            client: client,
            runner: runner,
            concatenator: concatenator
        )
    }
}

// MARK: - Fakes
private extension GeneratorTests {
    
    struct RunnerDummy: Runner {
        func run(_ code: String) throws -> Output {
            ("","",0)
        }
    }
    
    struct ClientStub: Client {
        let stub: Result<String, Error>
        func send(userMessages: [String]) async throws -> String {
            try stub.get()
        }
    }
    
    struct ClientDummy: Client {
        func send(userMessages: [String]) async throws -> String {
            ""
        }
    }
    struct RunnerStub: Runner {
        let stub: Result<Output, Error>
        func run(_ code: String) throws -> Output {
            try stub.get()
        }
    }
    
}

// MARK: - Factories
private extension GeneratorTests {
    func anyProcessOutput() -> Runner.Output {
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
}


infix operator ++
func ++(lhs: String, rhs: String) -> String {
    lhs + "\n" + rhs
}

infix operator .*
@discardableResult
func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}
