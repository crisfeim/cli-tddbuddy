// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public class Coordinator {
    
    public protocol Iterator {
        func iterate<T>(nTimes n: Int, until condition: (T) -> Bool, action: () async throws -> T) async throws -> T
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
        let output = try await iterator.iterate(
            nTimes: maxIterationCount,
            until: { isSuccess($0) }
        ) {
            try await self.generateCode(systemPrompt: systemPrompt, from: specs)
        }
        
        try persistor.persist(output.generatedCode, outputURL: outputFileURL)
        return output
    }
    
    private func generateCode(systemPrompt: String, from specs: String) async throws -> Output {
        let messages: [Client.Message] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": specs]
        ]
        
        let generated = try await client.send(messages: messages)
        let concatenated = generated + "\n" + specs
        let processOutput = try runner.run(concatenated)
        return (generated, processOutput)
    }
    
    private func isSuccess(_ o: Output) -> Bool { o.procesOutput.exitCode == 0 }
}
