import Foundation

/// Un mensaje de la conversación mostrado en pantalla.
struct ChatTurn: Identifiable, Equatable {
    enum Role { case user, assistant }

    let id = UUID()
    let role: Role
    let text: String
    let date = Date()
}
