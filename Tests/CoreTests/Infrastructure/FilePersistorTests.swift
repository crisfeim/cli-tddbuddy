// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
class FilePersistorTests: XCTestCase {
    class FilePersistor {
        func persist(_ string: String, outputURL: URL) throws {
            try string.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }
    
    override func setUp() async throws {
        setupEmptyState()
    }
    
    override func tearDown() async throws {
        cleanTestsArtifacts()
    }
    
    func test_persist_savesStringToDisk() throws {
        let sut = FilePersistor()
        try sut.persist("any string", outputURL: temporaryFileURL())
        XCTAssertEqual(try String(contentsOf: temporaryFileURL()), "any string")
    }
    
    func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("output.txt")
    }
    
    func cleanTestsArtifacts() {
        try? removeTemporyFile()
    }
    
    func setupEmptyState() {
       try? removeTemporyFile()
    }
    
    func removeTemporyFile() throws {
        try FileManager.default.removeItem(at: temporaryFileURL())
    }
}
