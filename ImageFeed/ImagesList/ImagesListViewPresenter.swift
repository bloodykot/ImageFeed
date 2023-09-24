//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 24.02.2024.
//

import Foundation

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func shouldFetchPhotosNextPage(lastImage: Int, getOnlyFirstPageIn UITestMode: Bool)
    func changeLike(currentImage: Int) -> Bool
    func setLargeImageURL(currentImage: Int)
    func getPhotosCount() -> Int
    func thumbImageURL(currentImage: Int) -> URL?
    func createdAt(currentImage: Int) -> Date?
    func isLiked(currentImage: Int) -> Bool
    func imageWidth(currentImage: Int) -> Double?
    func imageHeight(currentImage: Int) -> Double?
    func updateTableViewAnimated()
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var testMode: Bool = false
    var testMode2: Bool = false
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.updateTableViewAnimated(notification: notification)
            }
        
        imagesListService.fetchPhotosNextPage(useMockDataIn: testMode) { _ in
        }
        guard testMode == false else {
            updateTableViewAnimated()
            return
        }
    }
    
    func updateTableViewAnimated(notification: Notification) {
        updateTableViewAnimated()
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = testMode ? 10 : imagesListService.photos.count
        guard testMode2 == false else {
            for siglePhoto in MockPhoto().photos {
                self.photos.append(siglePhoto)
            }
            return
        }
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.performBatchUpdates(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func shouldFetchPhotosNextPage(lastImage: Int, getOnlyFirstPageIn UITestMode: Bool) {
        if UITestMode && imagesListService.photos.count >= 10 {
            return
        }
        if lastImage + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage(useMockDataIn: testMode) { _ in
            }
        }
    }
    
    func changeLike(currentImage: Int) -> Bool {
        let photo = imagesListService.photos[currentImage]
        UIBlockingProgressHUD.show()
        let likeStatus = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id, isLike: likeStatus, useMockDataIn: testMode) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                //cell.setIsLiked(self.photos[currentRow].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.view?.showLikeAlert(error: error)
            }
        }
        return likeStatus 
    }
    
    func setLargeImageURL(currentImage: Int) {
        ImagesListService.shared.urlLargeImage = URL(string: photos[currentImage].largeImageURL)
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func thumbImageURL(currentImage: Int) -> URL? {
        URL(string: photos[currentImage].thumbImageURL)
    }
    
    func createdAt(currentImage: Int) -> Date? {
        photos[currentImage].createdAt
    }
    
    func isLiked(currentImage: Int) -> Bool {
        photos[currentImage].isLiked
    }
    
    func imageWidth(currentImage: Int) -> Double? {
        return photos[currentImage].size.width
    }
    
    func imageHeight(currentImage: Int) -> Double? {
        return photos[currentImage].size.height
    }
}
