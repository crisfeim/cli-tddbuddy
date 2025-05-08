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
        
        func generateCode(sourceURL: URL) async throws {
            let _ = try reader.read(sourceURL)
        }
    }
    
    func test_generate_deliversErrorOnReaderError() async throws {
        struct FileReaderStub: FileReader {
            let result: Result<String, Error>
            func read(_: URL) throws -> String {
                try result.get()
            }
        }
        let reader = FileReaderStub(result: .failure(anyError()))
        let coordinator = Coordinator(reader: reader)
        do {
            try await coordinator.generateCode(sourceURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
}
