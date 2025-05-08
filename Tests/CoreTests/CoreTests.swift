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
    
    func test_generate_deliversCodeOnClientSuccess() async throws {
        struct ClientStub: Client {
            let stub: String
            func send(systemPrompt: String, userMessages: [String]) async throws -> String {
                return stub
            }
        }
        
        let client = ClientStub(stub: "any generated code")
        let generator = Generator(client: client)
        let generated = try await generator.generateCode(from: "any specs")
        XCTAssertEqual(generated, "any generated code")
    }
    
    func test_generate_deliversErrorOnClientError() async throws {
        struct ClientStub: Client {
            let stub: NSError
            func send(systemPrompt: String, userMessages: [String]) async throws -> String {
                throw stub
            }
        }
        
        let client = ClientStub(stub: NSError(domain: "any error", code: 0))
        let generator = Generator(client: client)
        do {
            let _ = try await generator.generateCode(from: "any specs")
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "any error", code: 0))
        }
    }
   
}
