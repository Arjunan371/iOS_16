//
//  ApiManager.swift
//  iOS_16
//
//  Created by Arjunan on 18/08/25.
//

import Foundation

struct Endpoint {
    let baseUrl: String
    let path: String
    let queryItems: [String: Any?]

    init(
        baseUrl: String = "https://api.example.com",
        path: String = "",
        queryItems: [String: Any?] = [:]
    ) {
        self.baseUrl = baseUrl
        self.path = path
        self.queryItems = queryItems
    }

    var url: URL? {
        guard var components = URLComponents(string: baseUrl) else { return nil }

        if !path.isEmpty {
            components.path = (components.path as NSString).appendingPathComponent(path)
        }

        let items = queryItems.compactMap { key, value -> URLQueryItem? in
            guard let value = value else { return nil }
            let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return URLQueryItem(name: key, value: encodedValue)
        }

        if !items.isEmpty {
            components.queryItems = items
        }

        return components.url
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    var accessToken: String? {
        KeychainHelper.read("accessToken")
    }
    
    var refreshToken: String? {
        KeychainHelper.read("refreshToken")
    }
    
    var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    // MARK: - Refresh token logic
    private func refreshAccessToken() async -> Bool {
        guard let refreshToken = refreshToken else { return false }
        
        guard let url = ApiLink.refreshUrl.url else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["refreshToken": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return false
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let newToken = json["accessToken"] as? String {
            KeychainHelper.save("accessToken", value: newToken)
            return true
        }
        
        return false
    }
    
    // MARK: - Request handler with token refresh
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Any? = nil,
        responseType: T.Type
    ) async -> T? {
        
        guard let url = endpoint.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Merge headers
        let finalHeaders = defaultHeaders.merging(headers ?? [:]) { _, new in new }
        finalHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        // Body
        if let body = body {
            if let dict = body as? [String: Any] {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: dict)
            } else if let encodable = body as? Encodable {
                urlRequest.httpBody = try? JSONEncoder().encode(encodable)
            }
        }
        
        // Perform request
        guard let (data, response) = try? await URLSession.shared.data(for: urlRequest),
              let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        
        // If token expired, try refresh
        if httpResponse.statusCode == 401 {
            let refreshed = await refreshAccessToken()
            if refreshed {
                // retry once with new token
                return await request(endpoint: endpoint,
                                     method: method,
                                     headers: headers,
                                     body: body,
                                     responseType: responseType)
            } else {
                // Logout user
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
                return nil
            }
        }
        
        // Normal success response
        guard (200..<300).contains(httpResponse.statusCode) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

struct ApiLink {
    static let sampleUrl = Endpoint(path: "/user/userOut", queryItems: ["userId": "123456789"])
    static let refreshUrl = Endpoint(path: "/user/userOut", queryItems: ["userId": "123456789"])
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}

