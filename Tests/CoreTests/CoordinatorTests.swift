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
            let specs = try reader.read(specsFileURL)
            let output = try await generator.generateCode(from: specs)
            try persistor.persist(output.generatedCode, outputURL: outputFileURL)
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
        let reader = FileReaderStub(result: .failure(anyError()))
        let coordinator = makeSUT(reader: reader)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
        let reader = FileReaderStub(result: .success(""))
        let coordinator = makeSUT(reader: reader)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnGeneratorError() async throws {
      
        
        let generator = GeneratorStub(result: .failure(anyError()))
        let coordinatior = makeSUT(generator: generator)
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnGeneratorSuccess() async throws {
        let generator = GeneratorStub(result: .success(anyGeneratedOutput()))
        let coordinatior = makeSUT(generator: generator)
        do {
            try await coordinatior.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
        let persistor = PersistorStub(result: .failure(anyError()))
        let coordinator = makeSUT(persistor: persistor)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
            XCTFail()
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }
    
    func test_generateAndSaveCode_deliversNoErrorOnPersistenceSuccess() async throws {
        let persistor = PersistorStub(result: .success(()))
        let coordinator = makeSUT(persistor: persistor)
        do {
            try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        } catch {
            XCTFail()
        }
    }
    
    func test_generateAndSaveCode_generatesCodeFromReadFile() async throws {
        
        final class GeneratorSpy: Generator {
            var specs: String?
            func generateCode(from specs: String) async throws -> Output {
                self.specs = specs
                return ("", ("", "", 0))
            }
        }
        
        let reader = FileReaderStub(result: .success(anyString()))
        let generatorSpy = GeneratorSpy()
        let coordinator = makeSUT(reader: reader, generator: generatorSpy)
        
        try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        
        XCTAssertEqual(generatorSpy.specs, anyString())
    }
    
    func test_generateAndSaveCode_persistsGeneratedCode() async throws {
        class PersistorSpy: Persistor {
            var persistedString: String?
            func persist(_ string: String, outputURL: URL) throws {
                persistedString = string
            }
        }
        
        let generator = GeneratorStub(result: .success(anyGeneratedOutput()))
        let persistorSpy = PersistorSpy()
        
        let coordinator = makeSUT(generator: generator, persistor: persistorSpy)
        
        try await coordinator.generateAndSaveCode(specsFileURL: anyURL(), outputFileURL: anyURL())
        XCTAssertEqual(persistorSpy.persistedString, anyGeneratedOutput().generatedCode)
        
    }
    
    private func makeSUT(
        reader: FileReader = FileReaderDummy(),
        generator: Generator = GeneratorDummy(),
        persistor: Persistor = PersistorDummy()
    ) -> Coordinator {
        Coordinator(reader: reader, generator: generator, persistor: persistor)
    }
    
    struct PersistorStub: Persistor {
        let result: Result<Void, Error>
        func persist(_ string: String, outputURL: URL) throws {
            try result.get()
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
    func anyString() -> String {
        "any string"
    }
    func anyGeneratedOutput() -> Generator.Output {
        ("any generated code", output: ("any stdout", "any stdrr", 1))
    }
}
