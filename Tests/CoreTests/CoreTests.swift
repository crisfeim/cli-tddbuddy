// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

import XCTest

class CoreTests: XCTestCase {
    
    protocol Client {
        func send(userMessages: [String]) async throws -> String
    }
    
    protocol Runner {
        typealias Output = (stdout: String, stderr: String, exitCode: Int)
        func run(_ code: String) throws -> Output
    }
    
    final class Generator {
        typealias Concatenator = (String, String) -> String
        let client: Client
        let runner: Runner
        let concatenator: Concatenator
        init(client: Client, runner: Runner, concatenator: @escaping Concatenator) {
            self.client = client
            self.runner = runner
            self.concatenator = concatenator
        }
        
        typealias Output = (generatedCode: String, output: Runner.Output)
        
        func generateCode(from specs: String) async throws -> Output {
           let generated = try await client.send(userMessages: [])
           let concatenated = concatenator(specs, generated)
           let stdOut = try runner.run(concatenated)
          return (generated, stdOut)
        }
    }
    
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
    
    func test_generateCode_deliversCodeOnClientSuccess() async throws {
       
        let client = ClientStub(stub: .success("any generated code"))
        let generator = Generator(client: client, runner: RunnerDummy(), concatenator: ++)
        let (generated, _) = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(generated, "any generated code")
    }
    
    func test_generateCode_deliversErrorOnClientError() async throws {
        let client = ClientStub(stub: .failure(NSError(domain: "any error", code: 0)))
        let generator = Generator(client: client, runner: RunnerDummy(), concatenator: ++)
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
    
    func test_generateCode_deliversErrorOnRunnerError() async throws {
        let runner = RunnerStub(stub: .failure(NSError(domain: "any error", code: 0)))
        let generator = Generator(client: ClientDummy(), runner: runner, concatenator: ++)
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
    
    func test_generateCode_deliversOutputOnRunnerSuccess() async throws {
        let runner = RunnerStub(stub: .success(anyProcessOutput()))
        let generator = Generator(client: ClientDummy(), runner: runner, concatenator: ++)
        let (_, output) = try await generator.generateCode(from: "any specs")
    
        anyProcessOutput() .* { expected in
            XCTAssertEqual(output.stderr, expected.stderr)
            XCTAssertEqual(output.stdout, expected.stdout)
            XCTAssertEqual(output.exitCode, expected.exitCode)
        }
    }
    
    func test_generateCode_concatenatesCodeBeforeRunning() async throws {
        var called = false
        let generator = makeSUT(concatenator: { _,_ in called = true ; return "" })
        let _ = try await generator.generateCode(from: "any code")
        XCTAssertTrue(called)
    }
    
    func test_generatedCode_usesConcatenatedCodeAsRunnerInput() async throws {
        class RunnerSpy: Runner {
            var code: String?
            func run(_ code: String) throws -> Runner.Output {
                self.code = code
                return ("", "", 0)
            }
        }
        
        let clientStub = ClientStub(stub: .success("generated code"))
        let runner = RunnerSpy()
        let generator = makeSUT(client: clientStub, runner: runner, concatenator: ++)
        _ = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(runner.code, "any specs\ngenerated code")
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

private extension CoreTests {
    func anyProcessOutput() -> Runner.Output {
        ("", "", 0)
    }
}
