// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest

class SwiftRunnerTests: XCTestCase {
    
    struct SwiftRunner {
        private let fm = FileManager.default
        typealias ProcessOutput = (stdout: String, stderr: String, exitCode: Int)
        func run(_ code: String) throws -> ProcessOutput {
            let tmpURL = fm.temporaryDirectory.appendingPathComponent("generated.swift")
            try code.write(to: tmpURL, atomically: true, encoding: .utf8)
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
            process.arguments = [tmpURL.path]
            
            let stdOutPipe = Pipe()
            let stdErrPipe = Pipe()
            process.standardOutput = stdOutPipe
            process.standardError = stdErrPipe
            
            try process.run()
            process.waitUntilExit()

            let stdOutData = stdOutPipe.fileHandleForReading.readDataToEndOfFile()
            let stdErrData = stdErrPipe.fileHandleForReading.readDataToEndOfFile()
            
            return (
                stdout: String(data: stdOutData, encoding: .utf8) ?? "",
                stderr: String(data: stdErrData, encoding: .utf8) ?? "",
                exitCode: Int(process.terminationStatus)
            )
        }
    }
    
    func test_run_deliversRunsCode() throws {
        let sut = SwiftRunner()
        let swiftCode = #"print("hello world")"#
        let processOutput = try sut.run(swiftCode)
        let expectedStdout = "hello world\n"
        let expectedStderr = ""
        let expectedExitCode = 0
        
        XCTAssertEqual(processOutput.stdout, expectedStdout)
        XCTAssertEqual(processOutput.stderr, expectedStderr)
        XCTAssertEqual(processOutput.exitCode, expectedExitCode)
    }
}
