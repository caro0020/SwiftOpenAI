import SwiftUI
import UIKit

struct MessageBubble: View {
    let turn: ChatTurn
    private var isUser: Bool { turn.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }
            Text(turn.text)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .foregroundStyle(isUser ? .white : .primary)
                .background(isUser ? Color.orange : Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .textSelection(.enabled)
            if !isUser { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(turn: ChatTurn(role: .user, text: "¿Qué es SwiftUI?"))
        MessageBubble(turn: ChatTurn(role: .assistant, text: "Es el framework declarativo de Apple para crear interfaces."))
    }.padding()
}
