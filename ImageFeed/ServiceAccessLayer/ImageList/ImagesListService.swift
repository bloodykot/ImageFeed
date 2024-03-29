import UIKit

final class ImagesListService {
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    var urlLargeImage: URL?
    
    // MARK: - Private Properties
    private var currentTask: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlBuilder = URLRequestBuilder.shared
    
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchPhotosNextPage(useMockDataIn testMode: Bool, completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard testMode == false else {
            DispatchQueue.main.async {
                for siglePhoto in MockPhoto().photos {
                    self.photos.append(siglePhoto)
                    if self.lastLoadedPage != nil {
                        self.lastLoadedPage! += 1
                    } else {
                        self.lastLoadedPage = 1
                    }
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
            }
            return
        }
        
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
    
    func changeLike(photoId: String, isLike: Bool, useMockDataIn testMode: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard testMode == false else {
            DispatchQueue.main.async {
                self.photos[Int(photoId)!-1].isLiked.toggle()
                completion(.success(true))
            }
            
            return
        }
        let request: URLRequest
        if currentTask != nil {
            return
        }
        guard let request = likeDislikePhotoRequest(photoId: photoId, likeDislike: isLike) else {
            assertionFailure("Invalid like request")
            completion(.failure(NetworkError.invalidRequest))
            return
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
    
    func getLargeImageURL() -> URL {
        return urlLargeImage!
    }
    
    // MARK: - Private Methods
    private func makeFetchPhotosRequest(currentPage: Int) -> URLRequest? {
        var request=urlBuilder.makeHTTPRequest(
            path: "/photos",
            param: [URLQueryItem(name: "page", value: String(currentPage))],
            httpMethod: "GET")
        request?.setValue(
            "\(currentPage)",
            forHTTPHeaderField: "page")
        return request
    }
    
    private func likeDislikePhotoRequest(photoId: String, likeDislike isLiked: Bool) -> URLRequest? {
        let request=urlBuilder.makeHTTPRequest(
        path: "/photos/\(photoId)/like",
        httpMethod: isLiked ? "POST" : "DELETE",
        baseURLString: Constants.defaultAPIBaseURLString)
        return request
    }
}
