import UIKit

final class ImagesListService {
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private var currentTask: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlBuilder = URLRequestBuilder.shared
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchPhotosNextPage(completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        if currentTask != nil {
            return
        }
        guard let request = makeFetchPhotosRequest(currentPage: nextPage) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let urlSession = URLSession.shared
        currentTask = urlSession.objectTask(for: request) { [weak self]
            (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.currentTask = nil
            switch result {
            case .success(let photoResult):
                for siglePhoto in photoResult {
                    self.photos.append(Photo(result: siglePhoto))
                }
                if self.lastLoadedPage != nil {
                    self.lastLoadedPage! += 1
                } else {
                    self.lastLoadedPage = 1
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
            case .failure(let error):
                assertionFailure("Request has no result. Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        let request: URLRequest
        if currentTask != nil {
            return
        }
        if isLike {
            guard let requested = likePhotoRequest(photoId: photoId) else {
                assertionFailure("Invalid like request")
                completion(.failure(NetworkError.invalidRequest))
                return
            }
            request = requested
        } else {
            guard let requested = dislikePhotoRequest(photoId: photoId) else {
                assertionFailure("Invalid like request")
                completion(.failure(NetworkError.invalidRequest))
                return
            }
            request = requested
        }
        
        let urlSession = URLSession.shared
        currentTask = urlSession.postOrDeleteLike(for: request) { [weak self]
            (result: Result<Void, Error>) in
            guard let self = self else { return }
            self.currentTask = nil
            switch result {
            case .success():
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
                completion(.success(true))
            case .failure(let error):
                assertionFailure("Request has no result. Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeFetchPhotosRequest(currentPage: Int) -> URLRequest? {
        var request=urlBuilder.makeHTTPRequestWithParam(
            path: "/photos",
            param: [URLQueryItem(name: "page", value: String(currentPage))],
            httpMethod: "GET")
        request?.setValue(
            "\(currentPage)",
            forHTTPHeaderField: "page")
        return request
    }
    
    private func likePhotoRequest(photoId: String) -> URLRequest? {
        let request=urlBuilder.makeHTTPRequest(
        path: "/photos/\(photoId)/like",
        httpMethod: "POST",
        baseURLString: Constants.defaultAPIBaseURLString)
        return request
    }
    
    private func dislikePhotoRequest(photoId: String) -> URLRequest? {
        let request=urlBuilder.makeHTTPRequest(
        path: "/photos/\(photoId)/like",
        httpMethod: "DELETE",
        baseURLString: Constants.defaultAPIBaseURLString)
        return request
    }
}
