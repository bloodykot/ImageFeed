import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private var currentTask: URLSessionTask?
    
    private(set) var avatarURL: URL?
    
    private let urlBuilder = URLRequestBuilder.shared
    
    private init() {}
    
    func fetchProfileImageURL(userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeFetchProfileImageRequest(userName: userName) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let urlSession = URLSession.shared
        currentTask = urlSession.objectTask(for: request) { [weak self] 
            (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profilePhoto):
                guard let mediumPhoto = profilePhoto.profileImage?.medium else { return }
                self?.avatarURL = URL(string: mediumPhoto)
                completion(.success(mediumPhoto))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": mediumPhoto])
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makeFetchProfileImageRequest(userName: String) -> URLRequest? {
        urlBuilder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIBaseURLString)
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
