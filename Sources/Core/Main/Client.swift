// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


public protocol Client {
    typealias Message = [String: String]
    var model: String {get}
    func send(messages: [Message]) async throws -> String
}
