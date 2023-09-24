import Foundation

final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    
    private let storage: OAuth2TokenStorage
    
    private init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String = Constants.defaultAPIBaseURLString
    ) -> URLRequest? {
        guard
            let url = URL(string: baseURLString),
            let baseURL = URL(string: path, relativeTo: url)
        else {return nil}
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = httpMethod
        
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func makeHTTPRequest(
        path: String,
        param: [URLQueryItem],
        httpMethod: String
    ) -> URLRequest? {
        guard
            let url = URL(string: Constants.defaultAPIBaseURLString),
            let baseURL = URL(string: path, relativeTo: url)
        else {return nil}
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = path
        components.queryItems = param
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod
        
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
