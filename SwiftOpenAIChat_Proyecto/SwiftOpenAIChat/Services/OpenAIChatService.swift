import Foundation
import SwiftOpenAI   // https://github.com/jamesrochabrun/SwiftOpenAI

/// Único archivo que toca la librería SwiftOpenAI.
/// Si tu versión del paquete cambia nombres u opcionales, solo se ajusta aquí.
struct OpenAIChatService {
    private let service: any OpenAIService

    init(apiKey: String) {
        service = OpenAIServiceFactory.service(apiKey: apiKey)
    }

    func send(history: [ChatTurn], systemPrompt: String, model: String) async throws -> String {
        var messages: [ChatCompletionParameters.Message] = [
            .init(role: .system, content: .text(systemPrompt))
        ]
        messages += history.map {
            .init(role: $0.role == .user ? .user : .assistant, content: .text($0.text))
        }

        let parameters = ChatCompletionParameters(messages: messages, model: .custom(model))
        let result = try await service.startChat(parameters: parameters)
        // En versiones antiguas del paquete `choices`/`message` no son opcionales:
        // quita los "?" sobrantes si el compilador lo indica.
        return result.choices?.first?.message?.content ?? ""
    }
}
