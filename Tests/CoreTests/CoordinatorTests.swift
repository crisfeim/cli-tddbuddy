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
    
    protocol Persistor {
        func persist(_ string: String, outputURL: URL) throws
    }
    
    protocol Generator {
        typealias Output = (generatedCode: String, output: Runner.Output)
        func generateCode(from specs: String) async throws -> Output
    }
    
    class Coordinator {
        let reader: FileReader
        let generator: Generator
        let persistor: Persistor
        init(reader: FileReader, generator: Generator, persistor: Persistor) {
            self.reader = reader
            self.generator = generator
            self.persistor = persistor
        }
        
        func generateAndSaveCode(specsFileURL: URL, outputFileURL: URL) async throws {
            let _ = try reader.read(specsFileURL)
            let _ = try await generator.generateCode(from: "")
            let _ = try persistor.persist("", outputURL: outputFileURL)
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let coordinator = Coordinator(reader: reader, generator: GeneratorDummy(), persistor: PersistorDummy())
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let coordinator = Coordinator(reader: reader, generator: GeneratorDummy(), persistor: PersistorDummy())
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnGeneratorError() async throws {
      
        
        let generator = GeneratorStub(result: .failure(anyError()))
        let coordinatior = Coordinator(reader: FileReaderDummy(), generator: generator, persistor: PersistorDummy())
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnGeneratorSuccess() async throws {
        let generator = GeneratorStub(result: .success(anyGeneratedOutput()))
        let coordinatior = Coordinator(reader: FileReaderDummy(), generator: generator, persistor: PersistorDummy())
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
        struct PersistorStub: Persistor {
            let result: Result<Void, Error>
            func persist(_ string: String, outputURL: URL) throws {
                try result.get()
            }
        }
        
        let persistor = PersistorStub(result: .failure(anyError()))
        let coordinator = Coordinator(
            reader: FileReaderDummy(),
            generator: GeneratorDummy(),
            persistor: persistor
        )
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
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
    
    struct PersistorDummy: Persistor {
        func persist(_ string: String, outputURL: URL) throws {
        }
    }
}

private extension CoordinatorTests {
    func anyGeneratedOutput() -> Generator.Output {
        ("", output: ("", "", 0))
    }
}
