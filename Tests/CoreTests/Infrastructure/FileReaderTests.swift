// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest

extension FileManager {
    func read(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}

class FileReaderTests: XCTestCase {
    override func setUp() {
        setupEmptyState()
    }
    
    override func tearDown() {
        cleanTestsArtifacts()
    }
    
    func test_read_readsFileWhenExists() throws {
        let sut = FileManager.default
        let stringToWrite = "Hello, world!"
        try stringToWrite.write(to: temporaryFileURL(), atomically: true, encoding: .utf8)
        let content = try sut.read(temporaryFileURL())
        XCTAssertEqual(stringToWrite, content)
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
