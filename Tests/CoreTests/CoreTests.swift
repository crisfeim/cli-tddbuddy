// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

import XCTest

class CoreTests: XCTestCase {
    
    protocol Client {
        func send(userMessages: [String]) async throws -> String
    }
    
    protocol Runner {
        func run(_ code: String) throws -> String
    }
    
    final class Generator {
        let client: Client
        let runner: Runner
        
        init(client: Client, runner: Runner) {
            self.client = client
            self.runner = runner
        }
        
        typealias Output = (generatedCode: String, stdOut: String)
        
        func generateCode(from specs: String) async throws -> Output {
           let generated = try await client.send(userMessages: [])
           let stdOut = try runner.run("")
          return (generated, stdOut)
        }
    }
    
    struct RunnerDummy: Runner {
        func run(_ code: String) throws -> String {
            ""
        }
    }
    
    struct ClientStub: Client {
        let stub: Result<String, Error>
        func send(userMessages: [String]) async throws -> String {
            try stub.get()
        }
    }
    
    struct DummyClient: Client {
        func send(userMessages: [String]) async throws -> String {
            ""
        }
    }
    struct RunnerStub: Runner {
        let stub: Result<String, Error>
        func run(_ code: String) throws -> String {
            try stub.get()
        }
        
    }
    
    func test_generateCode_deliversCodeOnClientSuccess() async throws {
       
        let client = ClientStub(stub: .success("any generated code"))
        let generator = Generator(client: client, runner: RunnerDummy())
        let (generated, _) = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(generated, "any generated code")
    }
    
    func test_generateCode_deliversErrorOnClientError() async throws {
        let client = ClientStub(stub: .failure(NSError(domain: "any error", code: 0)))
        let generator = Generator(client: client, runner: RunnerDummy())
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
    
    func test_generateCode_deliversErrorOnRunnerError() async throws {
        let runner = RunnerStub(stub: .failure(NSError(domain: "any error", code: 0)))
        let generator = Generator(client: DummyClient(), runner: runner)
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
    
    func test_generateCode_deliversOutputOnRunnerSuccess() async throws {
        let runner = RunnerStub(stub: .success("any output"))
        let generator = Generator(client: DummyClient(), runner: runner)
        let (_, output) = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(output, "any output")
    }
}
