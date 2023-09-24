import UIKit

final class ProfileService {
    // MARK: - Public Properties
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    private let builder: URLRequestBuilder
    private(set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let urlSession: URLSession
    
    // MARK: - Initializers
    private init(builder: URLRequestBuilder = .shared, urlSession: URLSession = .shared) {
        self.builder = builder
        self.urlSession = urlSession
    }
    
    // MARK: - Public Methods
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        guard let request = makeFetchProfileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] 
            (result: Result<ProfileResult, Error>) in
            self?.currentTask = nil
            switch result {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeFetchProfileRequest( ) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET")
    }
}
