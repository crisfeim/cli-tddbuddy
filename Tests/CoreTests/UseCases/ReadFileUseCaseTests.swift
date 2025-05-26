// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

import XCTest
import Core

final class ReadFileUseCaseTests: XCTest {
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let sut = makeSUT(reader: reader)
        
        await XCTAssertThrowsErrorAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let sut = makeSUT(reader: reader)
        
        await XCTAssertNoThrowAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    // MARK: - Helpers
    private func makeSUT(reader: FileReader) -> Coordinator {
        Coordinator(
            reader: reader,
            client: ClientDummy(),
            runner: RunnerDummy(),
            persistor: PersistorDummy(),
            iterator: Iterator()
        )
    }
    
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anySystemPrompt() -> String {
        "any system prompt"
    }
    
}
