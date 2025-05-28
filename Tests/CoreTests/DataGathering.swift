// © 2025  Cristian Felipe Patiño Rojas. Created on 28/5/25.

import XCTest
import Core

class DataGatheringTests: XCTestCase {
    final class IterationRecorder {
        private var date: Date?
        private var code: String?
        var iterations: [DataGatheringTests.Iteration] = []

        func recordGeneratedCode(_ code: String, at date: Date) {
            self.code = code
            self.date = date
        }

        func recordOutput(_ output: Runner.ProcessOutput) {
            guard let date = date, let code = code else {
                print("⚠️ Skipped iteration: incomplete data")
                return
            }
            iterations.append(
                .init(
                    startDate: date,
                    generatedCode: code,
                    exitCode: output.exitCode,
                    stdErr: output.stderr,
                    stdOut: output.stdout
                )
            )
            self.code = nil
            self.date = nil
        }
    }
    
    struct GatheredData: Equatable {
        let testId: String
        let modelName: String
        let executions: [Execution]
    }

    struct Execution: Equatable {
        let startDate: Date
        let iterations: [Iteration]
    }

    struct Iteration: Equatable {
        let startDate: Date
        let generatedCode: String
        let exitCode: Int
        let stdErr: String?
        let stdOut: String?
    }
    
    struct Specs {
        let id: String
        let content: String
    }
    
    class DataGatherer {
        let client: Client
        let runner: Runner
        let currentDate: () -> Date
        
        init(client: Client, runner: Runner, currentDate: @escaping () -> Date = Date.init) {
            self.client = client
            self.runner = runner
            self.currentDate = currentDate
        }
        
        func gatherData(systemPrompt: String, specs: Specs, executionCount: Int, iterationCount: Int) async throws -> GatheredData {
            
            class ClientSpy: Client {
                let client: Client
                
                init(client: Client, onResponse: @escaping (String) -> Void) {
                    self.client = client
                    self.onResponse = onResponse
                }
                var model: String {client.model}
                let onResponse: (String) -> Void
                func send(messages: [Message]) async throws -> String {
                    let response = try await client.send(messages: messages)
                    onResponse(response)
                    return response
                }
            }
            
            class RunnerSpy: Runner {
                let runner: Runner
                
                init(runner: Runner, onProcessOutput: @escaping (ProcessOutput) -> Void) {
                    self.runner = runner
                    self.onProcessOutput = onProcessOutput
                }
                let onProcessOutput: (ProcessOutput) -> Void
                func run(_ code: String) throws -> ProcessOutput {
                    let output = try runner.run(code)
                    onProcessOutput(output)
                    return output
                }
            }
            
            var executions = [Execution]()
            
            let currentDate = currentDate
            for _ in (1...executionCount) {
                let initialTimestamp = currentDate()
                let recorder = IterationRecorder()
                let clientSpy = ClientSpy(client: client) { [weak recorder] in
                    recorder?.recordGeneratedCode($0, at: currentDate())
                }
                let runnerSpy = RunnerSpy(runner: runner) { [weak recorder] in
                    recorder?.recordOutput($0)
                }
                let coordinator = Coordinator(client: clientSpy, runner: runnerSpy)
                let _ = try await coordinator.generateCode(
                    systemPrompt: systemPrompt,
                    specs: specs.content,
                    maxIterationCount: iterationCount
                )
                executions.append(
                    Execution(
                        startDate: initialTimestamp,
                        iterations: recorder.iterations
                    )
                )
            }
           
            return GatheredData(testId: specs.id, modelName: client.model, executions: executions)
        }
    }

    func test() async throws {
        struct ClientStub: Client {
            let model: String
            let result: String
            func send(messages: [Message]) async throws -> String {
                result
            }
        }
        
        struct RunnerStub: Runner {
            let result: ProcessOutput
            func run(_ code: String) throws -> ProcessOutput {
                return result
            }
        }
        
        let executionCount = 5
        let iterationCount = 5
        let timestamp = Date()
        let client = ClientStub(model: "fake model", result: "any generated code")
        let runner = RunnerStub(result: (stdout: "", stderr: "any stderr", exitCode: 1))
        let sut = DataGatherer(client: client, runner: runner, currentDate: { timestamp })
        let specs = Specs(
            id: "adder_spec",
            content: """
            func test_adder() {
                let sut = Adder(1,3)
                assert(sut.result == 4)
            }
            test_adder()
            """
        )
 
        let data = try await sut.gatherData(
            systemPrompt: "any system prompt",
            specs: specs,
            executionCount: executionCount,
            iterationCount: iterationCount
        )
        
        let iteration = Iteration(
            startDate: timestamp,
            generatedCode: "any generated code",
            exitCode: 1,
            stdErr: "any stderr",
            stdOut: ""
        )
        
        let iterations = Array(repeating: iteration, count: iterationCount)
        let execution =  Execution(startDate: timestamp, iterations: iterations)
        let executions = Array(repeating: execution, count: executionCount)
        
        let expectedData = GatheredData(
            testId: "adder_spec",
            modelName: "fake model",
            executions: executions
        )
        
        XCTAssertEqual(data, expectedData)
    }
}
