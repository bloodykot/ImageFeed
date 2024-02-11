import Foundation

final class OAuth2Service {
    // MARK: - Public Properties
    //static let shared = OAuth2Service()
    var isAuthenticated: Bool {
        storage.token != nil
    }
    
    // MARK: - Private Properties
    private let urlSession: URLSession
    private let storage: OAuth2TokenStorage
    private let builder: URLRequestBuilder
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    init(
        urlSession: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuilder = .shared) {
        self.urlSession = urlSession
        self.storage = storage
        self.builder = builder
    }
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage.shared.token
        }
        set {
            OAuth2TokenStorage.shared.token = newValue
        }
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard code != lastCode else { return }
        currentTask?.cancel()
        lastCode = code
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self]
            (result: Result<OAuthTokenResponseBody, Error>) in
            
            self?.currentTask = nil
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self?.storage.token = authToken
                completion(.success(authToken))
                self?.currentTask = nil
            case .failure(let error):
                completion(.failure(error))
                self?.currentTask = nil
                self?.lastCode = nil
            }
        }
        currentTask?.resume()
    }
}

extension OAuth2Service {
    private func fetchOAuthBody(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
            let decoder = JSONDecoder()
            return urlSession.objectTask(for: request) { (result: Result<Data, Error>) in
                let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                    Result {try decoder.decode(OAuthTokenResponseBody.self, from: data)}
                }
                completion(response)
            }
        }
    
    private func authTokenRequest(code: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURLString: Constants.baseURLString
        )
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}
