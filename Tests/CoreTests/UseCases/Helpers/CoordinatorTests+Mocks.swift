// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

import Foundation
import Core


// Stubs
extension CoordinatorTests {
    struct RunnerStub: Runner {
        let result: Result<ProcessOutput, Error>
        func run(_ code: String) throws -> ProcessOutput {
            try result.get()
        }
    }
    
    
    struct FileReaderStub: FileReader {
        let result: Result<String, Error>
        func read(_: URL) throws -> String {
            try result.get()
        }
    }
    
    struct PersistorStub: Persistor {
        let result: Result<Void, Error>
        func persist(_ string: String, outputURL: URL) throws {
            try result.get()
        }
    }
    
    struct ClientStub: Client {
        let result: Result<String, Error>
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            try result.get()
        }
    }
}


// Dummies
extension CoordinatorTests {
    
    struct PersistorDummy: Persistor {
        func persist(_ string: String, outputURL: URL) throws {
        }
    }
    
    struct ClientDummy: Client {
        func send(systemPrompt: String, userMessage: String) async throws -> String {
            ""
        }
    }
    
    struct RunnerDummy: Runner {
        func run(_ code: String) throws -> ProcessOutput {
            (stdout: "", stderr: "", exitCode: 0)
        }
    }
    
    struct FileReaderDummy: FileReader {
        func read(_ url: URL) throws -> String {
            ""
        }
    }
}
