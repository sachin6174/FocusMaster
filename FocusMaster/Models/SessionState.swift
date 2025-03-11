import Foundation

struct SessionState: Codable {
    let mode: String
    let elapsedTime: TimeInterval
    let points: Int
    let sessionID: UUID
    let startTime: Date
    let userID: UUID
}

class SessionStateManager {
    static let shared = SessionStateManager()
    private let defaults = UserDefaults.standard
    private let key = "savedSessionState"
    
    func saveSession(_ state: SessionState) {
        if let encoded = try? JSONEncoder().encode(state) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func loadSession() -> SessionState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SessionState.self, from: data)
    }
    
    func clearSession() {
        defaults.removeObject(forKey: key)
    }
}
