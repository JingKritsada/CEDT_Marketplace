import Foundation

final class ImageUploadService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenInterceptor: TokenInterceptor

    init(
        session: URLSession = .shared,
        tokenInterceptor: TokenInterceptor = .shared
    ) {
        self.session = session
        self.tokenInterceptor = tokenInterceptor
        decoder = JSONDecoder()
    }

    func uploadListingImages(_ images: [Data]) async throws -> [String] {
        guard !images.isEmpty else {
            return []
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        let accessToken = try await resolveAccessToken()
        let request = try buildRequest(boundary: boundary, accessToken: accessToken)
        let body = makeBody(boundary: boundary, images: images)

        do {
            let (data, response) = try await session.upload(for: request, from: body)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }

            if httpResponse.statusCode == 401 {
                let newToken = try await tokenInterceptor.refreshTokens()
                let retryRequest = try buildRequest(boundary: boundary, accessToken: newToken)
                let (retryData, retryResponse) = try await session.upload(for: retryRequest, from: body)
                guard let retryHttp = retryResponse as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                return try handleResponse(retryHttp, data: retryData)
            }

            return try handleResponse(httpResponse, data: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).domain == NSURLErrorDomain {
                throw NetworkError.noInternet
            }
            throw NetworkError.unknown
        }
    }

    private func resolveAccessToken() async throws -> String {
        if let accessToken = KeychainManager.shared.accessToken {
            return accessToken
        }

        return try await tokenInterceptor.refreshTokens()
    }

    private func buildRequest(boundary: String, accessToken: String?) throws -> URLRequest {
        guard let url = Endpoint.uploadImages.url(baseURL: AppConfig.baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let accessToken else {
            throw NetworkError.unauthorized
        }

        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeBody(boundary: String, images: [Data]) -> Data {
        var body = Data()

        for (index, image) in images.enumerated() {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"image-\(index).jpg\"\r\n")
            body.appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(image)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        return body
    }

    private func handleResponse(_ response: HTTPURLResponse, data: Data) throws -> [String] {
        switch response.statusCode {
        case 200 ... 299:
            struct UploadResponse: Decodable {
                let urls: [String]
            }

            do {
                return try decoder.decode(UploadResponse.self, from: data).urls
            } catch {
                throw NetworkError.decodingFailed
            }
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 422:
            let message = decodeErrorMessage(from: data) ?? "Invalid input."
            throw NetworkError.validationError(message)
        default:
            let message = decodeErrorMessage(from: data) ?? "Server error."
            throw NetworkError.serverError(message)
        }
    }

    private func decodeErrorMessage(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let message: String?
        }

        return try? decoder.decode(ErrorResponse.self, from: data).message
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
