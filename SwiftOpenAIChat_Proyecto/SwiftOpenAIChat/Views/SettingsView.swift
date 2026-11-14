import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var keyDraft = ""
    @State private var geminiDraft = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Modo demostración") {
                    Toggle("Respuestas simuladas", isOn: $viewModel.demoMode)
                    Text("No usa internet ni la API key. Solo sirve para mostrar el flujo de la app.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Proveedor de IA") {
                    Picker("Proveedor", selection: $viewModel.provider) {
                        Text("OpenAI").tag("openai")
                        Text("Google Gemini").tag("gemini")
                    }
                    .pickerStyle(.segmented)
                }
                if viewModel.provider == "gemini" {
                    Section("API key de Google (AI Studio)") {
                        SecureField("AIza...", text: $geminiDraft)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        Text("Se guarda de forma segura en el Keychain del dispositivo.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Section("Modelo de Gemini") {
                        TextField("gemini-3.5-flash", text: $viewModel.geminiModel)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                } else {
                Section("API key de OpenAI") {
                    SecureField("sk-...", text: $keyDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text("Se guarda de forma segura en el Keychain del dispositivo.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Modelo") {
                    Picker("Modelo", selection: $viewModel.model) {
                        ForEach(ChatViewModel.availableModels, id: \.self) { Text($0) }
                    }
                }
                }
                Section("Instrucciones del asistente") {
                    TextField("Prompt de sistema", text: $viewModel.systemPrompt, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Ajustes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { viewModel.saveKey(keyDraft); viewModel.saveGeminiKey(geminiDraft); dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .onAppear { keyDraft = viewModel.apiKey; geminiDraft = viewModel.geminiKey }
        }
    }
}
