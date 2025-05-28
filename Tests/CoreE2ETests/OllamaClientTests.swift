// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Foundation
import Core

class OllamaClientTests: XCTestCase {
    
    func test_send_withRunningOllamaServer_returnsContent() async throws {
        let sut = OllamaClient(model: "llama3.2")
        let response = try await sut.send(messages: [["role": "user", "content": "hello"]])
        XCTAssert(!response.isEmpty)
    }
}
