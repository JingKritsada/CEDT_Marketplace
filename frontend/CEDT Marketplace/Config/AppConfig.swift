import Foundation

enum AppConfig {
    static let baseURL: URL = {
        guard let url = URL(string: "http://172.20.10.8:3003") else {
            preconditionFailure("Invalid base URL in AppConfig.")
        }
        return url
    }()

    static let studentEmailDomain = "student.chula.ac.th"
    static let appName = "CEDT Community Marketplace"
}
