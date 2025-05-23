// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public class Coordinator {
    
    public protocol Iterator {
        var count: Int {get}
        func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws
    }
    
    public protocol Generator {
        typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
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
   
    @discardableResult
    public func generateAndSaveCode(specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws -> Generator.Output {
        let specs = try reader.read(specsFileURL)
        var output: Generator.Output?
        try await iterator.iterate(nTimes: maxIterationCount, until: {output?.procesOutput.exitCode == 0}) {
            output = try await generator.generateCode(from: specs)
        }
        
        try output.flatMap { unwrapped in
            try persistor.persist(unwrapped.generatedCode, outputURL: outputFileURL)
        }
        return output!
    }
}
