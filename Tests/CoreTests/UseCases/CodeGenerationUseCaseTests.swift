// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

import Core

extension CoordinatorTests {
    func test_generateAndSaveCode_deliversErrorOnClientError() async throws {
        let client = ClientStub(result: .failure(anyError()))
        let coordinatior = makeSUT(client: client)
        
        await XCTAssertThrowsErrorAsync(
            try await coordinatior.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnClientSuccess() async throws {
        let client = ClientStub(result: .success("any genereted code"))
        let sut = makeSUT(client: client)
        await XCTAssertNoThrowAsync(
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
        )
    }
    
    private func makeSUT(client: Client) -> Coordinator {
        Coordinator(
            reader: FileReaderDummy(),
            client: client,
            runner: RunnerDummy(),
            persistor: PersistorDummy(),
            iterator: Iterator()
        )
    }
}
