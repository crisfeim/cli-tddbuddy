// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class IntegrationTests: XCTestCase {
    func test_adder_generation() async throws {
        let reader = FileManager.default
        let client = OllamaClient()
        let runner = SwiftRunner()
        let persistor = FilePersistor()
        let iterator = Iterator()
        let generator = Generator(client: client, runner: runner)
        let sut = Coordinator(
            reader: reader,
            generator: generator,
            persistor: persistor,
            iterator: iterator
        )
        let adderSpecs = specsURL("adder.swift.txt")
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("adder.swift.txt")
        try await sut.generateAndSaveCode(specsFileURL: adderSpecs, outputFileURL: tmpURL)
        
        let contents = try reader.read(tmpURL)
        
        XCTAssertEqual(contents.isEmpty, false)
    }
    
    func specsURL(_ filename: String) -> URL {
        inputFolder().appendingPathComponent(filename)
    }
    
    func testsResourceDirectory() -> URL {
        Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
    }
    
    func inputFolder() -> URL {
        testsResourceDirectory().appendingPathComponent("inputs")
    }
}
