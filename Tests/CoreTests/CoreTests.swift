// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

import XCTest

class CoreTests: XCTestCase {
    
    protocol Client {
        func send(systemPrompt: String, userMessages: [String]) async throws -> String
    }
    
    final class Generator {
        let client: Client
        
        init(client: Client) {
            self.client = client
        }
        
        func generateCode(from specs: String) async throws -> String {
            try await client.send(systemPrompt: "", userMessages: [])
        }
    }
    
    struct ClientStub: Client {
        let stub: Result<String, Error>
        func send(systemPrompt: String, userMessages: [String]) async throws -> String {
            try stub.get()
        }
    }
    
    func test_generate_deliversCodeOnClientSuccess() async throws {
       
        let client = ClientStub(stub: .success("any generated code"))
        let generator = Generator(client: client)
        let generated = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(generated, "any generated code")
    }
    
    func test_generate_deliversErrorOnClientError() async throws {
        let client = ClientStub(stub: .failure(NSError(domain: "any error", code: 0)))
        let generator = Generator(client: client)
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
   
}
