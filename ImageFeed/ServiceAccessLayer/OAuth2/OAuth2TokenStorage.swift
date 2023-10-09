import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "currentUser")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentUser")
        }
    }
}
