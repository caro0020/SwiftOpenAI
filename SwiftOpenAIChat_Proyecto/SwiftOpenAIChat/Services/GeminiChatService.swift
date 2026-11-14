import Foundation

/// Cliente de Google Gemini mediante su endpoint compatible con OpenAI (Chat Completions).
/// Usa URLSession: no agrega dependencias al proyecto.
struct GeminiChatService {
    struct ServiceError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    private struct ChatResponse: Decodable {
        struct Choice: Decodable {
            struct Msg: Decodable { let content: String? }
            let message: Msg
        }
        let choices: [Choice]
    }

    private struct APIError: Decodable {
        struct Detail: Decodable { let message: String }
        let error: Detail
    }

    private static let endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func send(history: [ChatTurn], systemPrompt: String, model: String) async throws -> String {
        var messages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        messages += history.map {
            ["role": $0.role == .user ? "user" : "assistant", "content": $0.text]
        }

        var request = URLRequest(url: URL(string: Self.endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["model": model, "messages": messages])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ServiceError(message: "Respuesta inválida del servidor.")
        }
        guard (200..<300).contains(http.statusCode) else {
            // Google puede devolver el error como objeto o como arreglo.
            let single = (try? JSONDecoder().decode(APIError.self, from: data))?.error.message
            let list = (try? JSONDecoder().decode([APIError].self, from: data))?.first?.error.message
            throw ServiceError(message: "Gemini (código \(http.statusCode)): " + (single ?? list ?? "error del servidor."))
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }
}
