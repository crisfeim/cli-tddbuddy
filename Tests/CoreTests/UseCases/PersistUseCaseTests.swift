// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

extension CoordinatorTests {
    
    func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
        let persistor = PersistorStub(result: .failure(anyError()))
        let sut = makeSUT(persistor: persistor)
        await XCTAssertThrowsErrorAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnPersistenceSuccess() async throws {
        let persistor = PersistorStub(result: .success(()))
        let sut = makeSUT(persistor: persistor)
        await XCTAssertNoThrowAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }

    private func makeSUT(persistor: Persistor) -> Coordinator {
        Coordinator(
            reader: FileReaderDummy(),
            client: ClientDummy(),
            runner: RunnerDummy(),
            persistor: persistor
        )
    }
}
