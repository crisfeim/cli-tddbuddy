// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


public protocol Runner {
    typealias Output = (stdout: String, stderr: String, exitCode: Int)
    func run(_ code: String) throws -> Output
}