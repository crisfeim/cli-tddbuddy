// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public typealias Concatenator = (String, String) -> String
public class Coordinator {
    
    public protocol Iterator {
        var count: Int {get}
        func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws
    }
    
    public protocol Generator {
        typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
        func generateCode(from specs: String) async throws -> Output
    }
    
    public typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
   
    private let reader: FileReader
    private let client: Client
    private let runner: Runner
    private let concatenator:Concatenator
    private let persistor: Persistor
    private let iterator: Iterator
    
    public init(
        reader: FileReader,
        client: Client,
        runner: Runner,
        concatenator: @escaping Concatenator,
        persistor: Persistor,
        iterator: Iterator
    ) {
        self.reader = reader
        self.client = client
        self.runner = runner
        self.concatenator = concatenator
        self.persistor = persistor
        self.iterator = iterator
    }
   
    @discardableResult
    public func generateAndSaveCode(systemPrompt: String, specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws -> Output {
        let specs = try reader.read(specsFileURL)
        var output: Generator.Output?
        try await iterator.iterate(nTimes: maxIterationCount, until: {output?.procesOutput.exitCode == 0}) {
            output = try await self.generateCode(systemPrompt: systemPrompt, from: specs)
        }
        
        try output.flatMap { unwrapped in
            try persistor.persist(unwrapped.generatedCode, outputURL: outputFileURL)
        }
        return output!
    }
    
    public func generateCode(systemPrompt: String, from specs: String) async throws -> Output {
        let generated = try await client.send(systemPrompt: systemPrompt, userMessage: specs)
        let concatenated = concatenator(generated, specs)
        let processOutput = try runner.run(concatenated)
        return (generated, processOutput)
    }
}

infix operator ++
public func ++(lhs: String, rhs: String) -> String {
    lhs + "\n" + rhs
}
