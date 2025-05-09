// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class FilePersistorTests: XCTestCase {
    
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
