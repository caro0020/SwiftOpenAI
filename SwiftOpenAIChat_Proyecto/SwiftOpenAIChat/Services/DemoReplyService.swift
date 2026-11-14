import Foundation

/// Respuestas de ejemplo para el modo demostración.
/// No usa internet ni la API key: sirve para mostrar el flujo de la app sin gastar saldo.
struct DemoReplyService {
    func reply(to text: String) async -> String {
        // Simula el tiempo de espera de una llamada real a la API.
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        let t = text.lowercased()
        let body: String
        if t.contains("hola") || t.contains("buenos") || t.contains("buenas") {
            body = "¡Hola! Soy el asistente de SwiftOpenAI. Pregúntame por SwiftUI, MVVM, Keychain, Git o las normas ISO del proyecto."
        } else if t.contains("swiftui") {
            body = "SwiftUI es el framework declarativo de Apple para crear interfaces. Describes cómo debe verse la pantalla según el estado y el sistema la actualiza solo."
        } else if t.contains("mvvm") {
            body = "MVVM separa la app en Modelo, Vista y ViewModel. Así la interfaz solo muestra el estado y la lógica vive en un lugar fácil de probar."
        } else if t.contains("keychain") || t.contains("clave") || t.contains("api key") {
            body = "La API key se guarda en el Keychain de iOS, que cifra los datos. Nunca se escribe en el código ni se sube al repositorio."
        } else if t.contains("iso") || t.contains("norma") || t.contains("estándar") || t.contains("estandar") {
            body = "El proyecto se alinea con ISO/IEC 25010 (calidad), 12207 y 29148 (ciclo de vida y requisitos), 27001 y OWASP MASVS (seguridad) y 29119 (pruebas)."
        } else if t.contains("git") || t.contains("github") {
            body = "El código se versiona con Git y se publica en GitHub: git init, git add, git commit y git push a la rama main."
        } else if t.contains("openai") || t.contains("api") {
            body = "En modo real, la app envía el historial a la API de OpenAI mediante el paquete SwiftOpenAI y muestra la respuesta del modelo."
        } else {
            body = "Esta es una respuesta de ejemplo. En modo real, aquí aparecería la respuesta generada por el modelo de OpenAI."
        }
        return "[Respuesta simulada] " + body
    }
}
