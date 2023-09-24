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
    func shouldFetchPhotosNextPage(lastRow: Int)
    func changeLike(currentRow: Int) -> Bool
    func setLargeImageURL(currentRow: Int)
    func getPhotosCount() -> Int
    func thumbImageURL(currentRow: Int) -> URL?
    func createdAt(currentRow: Int) -> Date?
    func isLiked(currentRow: Int) -> Bool
    func imageWidth(currentRow: Int) -> Double?
    func imageHeight(currentRow: Int) -> Double?
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
    
    func shouldFetchPhotosNextPage(lastRow: Int) {
        if lastRow + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage(useMockDataIn: testMode) { _ in
            }
        }
    }
    
    func changeLike(currentRow: Int) -> Bool {
        let photo = imagesListService.photos[currentRow]
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
    
    func setLargeImageURL(currentRow: Int) {
        ImagesListService.shared.urlLargeImage = URL(string: photos[currentRow].largeImageURL)
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func thumbImageURL(currentRow: Int) -> URL? {
        URL(string: photos[currentRow].thumbImageURL)
    }
    
    func createdAt(currentRow: Int) -> Date? {
        photos[currentRow].createdAt
    }
    
    func isLiked(currentRow: Int) -> Bool {
        photos[currentRow].isLiked
    }
    
    func imageWidth(currentRow: Int) -> Double? {
        return photos[currentRow].size.width
    }
    
    func imageHeight(currentRow: Int) -> Double? {
        return photos[currentRow].size.height
    }
}
