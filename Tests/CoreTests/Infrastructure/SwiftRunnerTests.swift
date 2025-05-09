// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import XCTest
import Core

class SwiftRunnerTests: XCTestCase {
    
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
