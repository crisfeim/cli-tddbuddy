// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import Foundation

public struct OllamaClient: Client {
    public let model: String
    private let url = "http://localhost:11434/api/chat"
    public init(model: String) {self.model = model}
    public func send(messages: [Message]) async throws -> String {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try makeBody(messages)
        //request.timeoutInterval = 10
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Response.self, from: data).message.content
    }
    
    private func makeBody(_ messages: [Message]) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "model": model,
            "messages": messages,
            "stream": false
        ], options: [])
    }

    struct Response: Decodable {
        let message: Message
        // MARK: - Message
        struct Message: Decodable {
            let role: String
            let content: String
        }
    }
}
