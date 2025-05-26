// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

import Foundation
import Core

extension CoordinatorTests {
    
    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        NSError(domain: "", code: 0)
    }
    
    func anyGeneratedCode() -> String {
        "any generated code"
    }
    
    func anyString() -> String {
        "any string"
    }
    
    func anySystemPrompt() -> String {
        "any system prompt"
    }
    
    func anySpecs() -> String {
        "any specs"
    }
    
    func anySuccessProcessOutput() -> Runner.ProcessOutput {
        ("", "", 0)
    }
    
    private static var failedExitCode: Int { 1 }
    func anyFailedProcessOutput() -> Runner.ProcessOutput {
        (stdout: "", stderr: "any stderr error", exitCode: Self.failedExitCode)
    }
}
