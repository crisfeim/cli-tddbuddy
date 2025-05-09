// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Foundation
import Core

class OllamaClientTests: XCTestCase {
    
    func test_send_withRunningOllamaServer_returnsContent() async throws {
        let sut = OllamaClient()
        let response = try await sut.send(systemPrompt: "", userMessage: "hello")
        XCTAssert(!response.isEmpty)
    }
}
