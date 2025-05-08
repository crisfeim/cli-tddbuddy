// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest

class CoordinatorTests: XCTestCase {
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    protocol FileReader {
        func read(_ url: URL) throws -> String
    }
    
    class Coordinator {
        let reader: FileReader
        
        init(reader: FileReader) {
            self.reader = reader
        }
        
        func generateAndSaveCode(specsFileURL: URL) async throws {
            let _ = try reader.read(specsFileURL)
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let coordinator = Coordinator(reader: reader)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let coordinator = Coordinator(reader: reader)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    struct FileReaderStub: FileReader {
        let result: Result<String, Error>
        func read(_: URL) throws -> String {
            try result.get()
        }
    }
}
