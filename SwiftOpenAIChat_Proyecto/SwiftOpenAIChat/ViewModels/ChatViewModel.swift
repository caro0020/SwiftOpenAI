import SwiftUI
import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    private let keyName = "openai_api_key"

    @Published var messages: [ChatTurn] = []
    @Published var input = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var apiKey: String
    @Published var geminiKey: String
    @AppStorage("model") var model = "gpt-4o-mini"
    @AppStorage("systemPrompt") var systemPrompt = "Eres un asistente útil. Responde en español, de forma clara y breve."

    @AppStorage("demoMode") var demoMode = false
    @AppStorage("provider") var provider = "openai"   // "openai" o "gemini"
    @AppStorage("geminiModel") var geminiModel = "gemini-3.5-flash"

    static let availableModels = ["gpt-4o-mini", "gpt-4o"]

    private let geminiKeyName = "gemini_api_key"

    var hasKey: Bool {
        let key = provider == "gemini" ? geminiKey : apiKey
        return !key.trimmingCharacters(in: .whitespaces).isEmpty
    }
    var canUse: Bool { hasKey || demoMode }
    var canSend: Bool { canUse && !isLoading && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init() {
        apiKey = KeychainStore.load(keyName) ?? ""
        geminiKey = KeychainStore.load("gemini_api_key") ?? ""
    }

    func saveKey(_ newKey: String) {
        apiKey = newKey.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKey.isEmpty ? KeychainStore.delete(keyName) : KeychainStore.save(apiKey, for: keyName)
    }

    func saveGeminiKey(_ newKey: String) {
        geminiKey = newKey.trimmingCharacters(in: .whitespacesAndNewlines)
        geminiKey.isEmpty ? KeychainStore.delete(geminiKeyName) : KeychainStore.save(geminiKey, for: geminiKeyName)
    }

    func clearChat() { messages.removeAll(); errorMessage = nil }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSend else { return }
        input = ""; errorMessage = nil
        messages.append(ChatTurn(role: .user, text: text))
        isLoading = true
        defer { isLoading = false }

        do {
            let reply: String
            if demoMode {
                reply = await DemoReplyService().reply(to: text)
            } else if provider == "gemini" {
                let service = GeminiChatService(apiKey: geminiKey)
                reply = try await service.send(history: messages, systemPrompt: systemPrompt, model: geminiModel)
            } else {
                let service = OpenAIChatService(apiKey: apiKey)
                reply = try await service.send(history: messages, systemPrompt: systemPrompt, model: model)
            }
            messages.append(ChatTurn(role: .assistant, text: reply.isEmpty ? "(respuesta vacía)" : reply))
        } catch {
            errorMessage = "No se pudo obtener respuesta: \(error.localizedDescription)"
        }
    }
}
