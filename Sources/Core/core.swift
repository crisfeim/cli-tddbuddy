// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.

public protocol Client {
    func send(userMessages: [String]) async throws -> String
}

public protocol Runner {
    typealias Output = (stdout: String, stderr: String, exitCode: Int)
    func run(_ code: String) throws -> Output
}


infix operator ++
public func ++(lhs: String, rhs: String) -> String {
    lhs + "\n" + rhs
}

public class Generator {
    
    public typealias Concatenator = (String, String) -> String
    public typealias Output = (generatedCode: String, output: Runner.Output)
    
    let client: Client
    let runner: Runner
    let concatenator: Concatenator
    
    public init(client: Client, runner: Runner, concatenator: @escaping Concatenator = (++)) {
        self.client = client
        self.runner = runner
        self.concatenator = concatenator
    }
    
    public func generateCode(from specs: String) async throws -> Output {
        let generated = try await client.send(userMessages: [])
        let concatenated = concatenator(specs, generated)
        let stdOut = try runner.run(concatenated)
        return (generated, stdOut)
    }
}
