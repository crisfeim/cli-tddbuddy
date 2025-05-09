// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


public protocol Client {
    func send(userMessage: String) async throws -> String
}
