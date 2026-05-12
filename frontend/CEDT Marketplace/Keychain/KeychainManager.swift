import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = Bundle.main.bundleIdentifier ?? "CEDTMarketplace"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    var accessToken: String? {
        get { read(key: accessTokenKey) }
        set { update(key: accessTokenKey, value: newValue) }
    }

    var refreshToken: String? {
        get { read(key: refreshTokenKey) }
        set { update(key: refreshTokenKey, value: newValue) }
    }

    func clearAll() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }

    private func update(key: String, value: String?) {
        guard let value else {
            delete(key: key)
            return
        }

        let data = Data(value.utf8)
        let query = baseQuery(key: key)

        if read(key: key) != nil {
            SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        } else {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }

    private func read(key: String) -> String? {
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query = baseQuery(key: key)
        SecItemDelete(query as CFDictionary)
    }

    private func baseQuery(key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
    }
}
