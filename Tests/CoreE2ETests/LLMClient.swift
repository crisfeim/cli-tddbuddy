// © 2025  Cristian Felipe Patiño Rojas. Created on 25/5/25.

import Foundation
import Core

public enum Clients {
    static let ollama = LLMClient<LLama32Response>(
        model: "llama3.2",
        url: "http://localhost:11434/api/chat"
    )
    
    static let llm7Gpt3dot5Turbo = LLMClient<Llm7Response>(
        model: "gpt-3.5-turbo",
        url: "https://api.llm7.io/v1/chat/completions"
    )
}

public struct LLMClient<T: Decodable>: Sendable {

    private let model: String
    private let url: String
    
    public init(model: String, url: String) {
        self.model = model
        self.url = url
    }
    
    public func send(systemPrompt: String, userMessage: String) async throws -> T {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try makeBody(systemPrompt, userMessage)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func makeBody(_ systemPrompt: String, _ userMessage: String) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "stream": false
        ], options: [])
    }
}

extension LLMClient: Client where T == Llm7Response {
    public func send(systemPrompt: String, userMessage: String) async throws -> String {
        try await send(systemPrompt: systemPrompt, userMessage: userMessage)
            .choices.first?.message.content ?? "(no content)"
    }
}

extension LLMClient where T == LLama32Response {
    func send(systemPrompt: String, userMessage: String) async throws -> String {
        try await send(systemPrompt: systemPrompt, userMessage: userMessage).message.content
    }
}

public struct Llm7Response: Decodable {
    let choices: [Choice]
    
    public struct Choice: Decodable {
        let message: Message
    }
    
    public struct Message: Decodable {
        let role: String
        let content: String
    }
}

public struct LLama32Response: Decodable {
    let message: Message
    struct Message: Decodable {
        let role: String
        let content: String
    }
}
