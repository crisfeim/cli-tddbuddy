// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest

class CoordinatorTests: XCTestCase {
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    typealias FileReader = (URL) throws -> String
    class Coordinator {
        let reader: FileReader
        
        init(reader: @escaping FileReader) {
            self.reader = reader
        }
        
        func generateCode(sourceURL: URL) async throws {
            let _ = try reader(sourceURL)
        }
    }
    
    func test_generate_deliversErrorOnReaderError() async throws {
        let coordinator = Coordinator(reader: { (_:URL) in throw self.anyError() })
        do {
            try await coordinator.generateCode(sourceURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
}
