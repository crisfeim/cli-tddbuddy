// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public protocol FileReader {
    func read(_ url: URL) throws -> String
}

public protocol Persistor {
    func persist(_ string: String, outputURL: URL) throws
}

public class Coordinator {
    public protocol Generator {
        typealias Output = (generatedCode: String, output: Runner.Output)
        func generateCode(from specs: String) async throws -> Output
    }
    
    private let reader: FileReader
    private let generator: Generator
    private let persistor: Persistor
    private let iterator: Iterator
    
    public init(reader: FileReader, generator: Generator, persistor: Persistor, iterator: Iterator) {
        self.reader = reader
        self.generator = generator
        self.persistor = persistor
        self.iterator = iterator
    }
    
    public func generateAndSaveCode(specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws {
        let specs = try reader.read(specsFileURL)
        var output: Generator.Output?
        try await iterator.iterate(nTimes: maxIterationCount, until: {output?.output.exitCode == 0}) {
            output = try await generator.generateCode(from: specs)
        }
        
        try output.flatMap { unwrapped in
            try persistor.persist(unwrapped.generatedCode, outputURL: outputFileURL)
        }
    }
}
