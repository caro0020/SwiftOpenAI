import SwiftUI
import UIKit

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.demoMode {
                    Text("MODO DEMOSTRACIÓN · respuestas simuladas, sin conexión a OpenAI")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                }
                if viewModel.messages.isEmpty { emptyState } else { messageList }
                if let error = viewModel.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.red).padding(.horizontal)
                }
                inputBar
            }
            .navigationTitle("SwiftOpenAI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { viewModel.clearChat() } label: { Image(systemName: "trash") }
                        .disabled(viewModel.messages.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView(viewModel: viewModel) }
            .onAppear { if !viewModel.canUse { showSettings = true } }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles").font(.system(size: 44)).foregroundStyle(.orange)
            Text("¿En qué te ayudo hoy?").font(.title3.bold())
            Text(viewModel.canUse ? "Escribe tu primer mensaje." : "Agrega tu API key en Ajustes para comenzar.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.messages) { MessageBubble(turn: $0).id($0.id) }
                    if viewModel.isLoading { ProgressView().frame(maxWidth: .infinity, alignment: .leading).padding(.leading) }
                }
                .padding()
            }
            .onChange(of: viewModel.messages) { _, _ in
                if let last = viewModel.messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Escribe un mensaje…", text: $viewModel.input, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(.secondarySystemBackground), in: Capsule())
            Button { Task { await viewModel.send() } } label: {
                Image(systemName: "arrow.up.circle.fill").font(.system(size: 34))
            }
            .tint(.orange)
            .disabled(!viewModel.canSend)
        }
        .padding()
    }
}

#Preview { ChatView(viewModel: ChatViewModel()) }
