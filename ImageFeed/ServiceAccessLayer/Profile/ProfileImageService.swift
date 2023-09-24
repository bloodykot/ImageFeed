import UIKit

final class ProfileImageService {
    // MARK: - Public Properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private var currentTask: URLSessionTask?
    private(set) var avatarURL: URL?
    private let urlBuilder = URLRequestBuilder.shared
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
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
    
    // MARK: - Private Methods
    private func makeFetchProfileImageRequest(userName: String) -> URLRequest? {
        urlBuilder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            baseURLString: Constants.defaultAPIBaseURLString)
    }
}
