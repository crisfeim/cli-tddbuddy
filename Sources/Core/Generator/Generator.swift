// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.


public typealias Concatenator = (String, String) -> String
public class Generator: Coordinator.Generator {
    
    
    let systemPrompt: String
    let client: Client
    let runner: Runner
    let concatenator: Concatenator
    
    public init(systemPrompt: String, client: Client, runner: Runner, concatenator: @escaping Concatenator) {
        self.systemPrompt = systemPrompt
        self.client = client
        self.runner = runner
        self.concatenator = concatenator
    }
    
    public func generateCode(from specs: String) async throws -> Output {
        let generated = try await client.send(systemPrompt: systemPrompt, userMessage: specs)
        let concatenated = concatenator(specs, generated)
        let processOutput = try runner.run(concatenated)
        return (generated, processOutput)
    }
}
