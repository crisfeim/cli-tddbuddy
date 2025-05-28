// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

public class Coordinator {
    
    public typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
   
    private let reader: FileReader
    private let client: Client
    private let runner: Runner
    private let persistor: Persistor
    private let iterator = Iterator()
    public init(
        reader: FileReader,
        client: Client,
        runner: Runner,
        persistor: Persistor
    ) {
        self.reader = reader
        self.client = client
        self.runner = runner
        self.persistor = persistor
    }
   
    @discardableResult
    public func generateAndSaveCode(systemPrompt: String, specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws -> Output {
        let specs = try reader.read(specsFileURL)
        let output = try await generateCode(
            systemPrompt: systemPrompt,
            specs: specs,
            maxIterationCount: maxIterationCount
        )
        try persistor.persist(output.generatedCode, outputURL: outputFileURL)
        return output
    }
    
    public func generateCode(systemPrompt: String, specs: String, maxIterationCount: Int = 1) async throws -> Output {
        var previousOutput: Output?
        return try await iterator.iterate(
            nTimes: maxIterationCount,
            until: { previousOutput = $0 ; return isSuccess($0) }
        ) {
            try await self.generateCode(systemPrompt: systemPrompt, from: specs, previous: previousOutput)
        }
    }
    
    private func generateCode(systemPrompt: String, from specs: String, previous: Output?) async throws -> Output {
        var messages: [Client.Message] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": specs]
        ]
        
        if let previous {
            messages.append([
                "role": "assistant",
                "content": "failed attempt.\ncode:\(previous.generatedCode)\nerror:\(previous.procesOutput.stderr)"
            ])
        }
        let generated = try await client.send(messages: messages)
        let concatenated = generated + "\n" + specs
        let processOutput = try runner.run(concatenated)
        return (generated, processOutput)
    }
    
    private func isSuccess(_ o: Output) -> Bool { o.procesOutput.exitCode == 0 }
}
