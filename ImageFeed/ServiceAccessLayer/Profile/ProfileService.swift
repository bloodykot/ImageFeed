import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private let builder: URLRequestBuilder
    
    private(set) var profile: Profile?
    
    private var currentTask: URLSessionTask?
    
    private let urlSession: URLSession
    
    private init(builder: URLRequestBuilder = .shared, urlSession: URLSession = .shared) {
        self.builder = builder
        self.urlSession = urlSession
    }
    
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
    
    private func makeFetchProfileRequest( ) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET")
    }
    
    private func fetch(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
            let decoder = JSONDecoder()
            let urlSession = URLSession.shared
            return urlSession.objectTask(for: request) { (result: Result<Data, Error>) in
                let response = result.flatMap { data -> Result<ProfileResult, Error> in
                    Result {try decoder.decode(ProfileResult.self, from: data)}
                }
                completion(response)
            }
        }    
}
