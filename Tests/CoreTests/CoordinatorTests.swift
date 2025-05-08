// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

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
    
    protocol Generator {
        typealias Output = (generatedCode: String, output: Runner.Output)
        func generateCode(from specs: String) async throws -> Output
    }
    
    class Coordinator {
        let reader: FileReader
        let generator: Generator
        init(reader: FileReader, generator: Generator) {
            self.reader = reader
            self.generator = generator
        }
        
        func generateAndSaveCode(specsFileURL: URL) async throws {
            let _ = try reader.read(specsFileURL)
            let _ = try await generator.generateCode(from: "")
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let coordinator = Coordinator(reader: reader, generator: GeneratorDummy())
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let coordinator = Coordinator(reader: reader, generator: GeneratorDummy())
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnGeneratorError() async throws {
      
        
        let generator = GeneratorStub(result: .failure(anyError()))
        let coordinatior = Coordinator(reader: FileReaderDummy(), generator: generator)
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnGeneratorSuccess() async throws {
        let generator = GeneratorStub(result: .success(anyGeneratedOutput()))
        let coordinatior = Coordinator(reader: FileReaderDummy(), generator: generator)
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    struct GeneratorStub: Generator {
        let result: Result<Generator.Output, Error>
        func generateCode(from specs: String) async throws -> Output {
            try result.get()
        }
    }
    
    struct FileReaderStub: FileReader {
        let result: Result<String, Error>
        func read(_: URL) throws -> String {
            try result.get()
        }
    }
    
    struct FileReaderDummy: FileReader {
        func read(_ url: URL) throws -> String {
            ""
        }
    }
    
    struct GeneratorDummy: Generator {
        func generateCode(from specs: String) async throws -> Output {
            ("", output: ("", "", 0))
        }
    }
}

private extension CoordinatorTests {
    func anyGeneratedOutput() -> Generator.Output {
        ("", output: ("", "", 0))
    }
}
