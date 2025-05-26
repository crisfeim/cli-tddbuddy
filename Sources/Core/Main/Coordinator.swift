// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public class Coordinator {
    
    public protocol Iterator {
        func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws
    }
    
    public typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
   
    private let reader: FileReader
    private let client: Client
    private let runner: Runner
    private let persistor: Persistor
    private let iterator: Iterator
    
    public init(
        reader: FileReader,
        client: Client,
        runner: Runner,
        persistor: Persistor,
        iterator: Iterator
    ) {
        self.reader = reader
        self.client = client
        self.runner = runner
        self.persistor = persistor
        self.iterator = iterator
    }
   
    @discardableResult
    public func generateAndSaveCode(systemPrompt: String, specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws -> Output {
        let specs = try reader.read(specsFileURL)
        var output: Output?
        try await iterator.iterate(nTimes: maxIterationCount, until: {output?.procesOutput.exitCode == 0}) {
            output = try await self.generateCode(systemPrompt: systemPrompt, from: specs)
        }
        
        try output.flatMap { unwrapped in
            try persistor.persist(unwrapped.generatedCode, outputURL: outputFileURL)
        }
        return output!
    }
    
    private func generateCode(systemPrompt: String, from specs: String) async throws -> Output {
        let generated = try await client.send(systemPrompt: systemPrompt, userMessage: specs)
        let concatenated = generated ++ specs
        let processOutput = try runner.run(concatenated)
        return (generated, processOutput)
    }
}

infix operator ++
public func ++(lhs: String, rhs: String) -> String {
    lhs + "\n" + rhs
}
