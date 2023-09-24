//
//  ImagesListViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 25.02.2024.
//
import ImageFeed
import Foundation

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var photosNextPageIsFetched: Bool = false
    var likeIsCanged: Bool = false
    var largeImageURLIsSetted: Bool = false
    var photosCounted: Bool = false
    var thumbImageURLExist: Bool = false
    var createdAtExist: Bool = false
    var isLikedIsDone: Bool = false
    var imageWidthGiven: Bool = false
    var imageHeightGiven: Bool = false
    var tableViewAnimatedIsUpdated = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {
        tableViewAnimatedIsUpdated = true
    }
    
    func shouldFetchPhotosNextPage(lastImage: Int, getOnlyFirstPageIn UITestMode: Bool) {
        photosNextPageIsFetched = true
    }
    
    func changeLike(currentImage: Int) -> Bool {
        likeIsCanged = true
        return likeIsCanged
    }
    
    func setLargeImageURL(currentImage: Int) {
        largeImageURLIsSetted = true
    }
    
    func getPhotosCount() -> Int {
        photosCounted = true
        return 10
    }
    
    func thumbImageURL(currentImage: Int) -> URL? {
        thumbImageURLExist = true
        return URL(string: "https://images.unsplash.com/photo-1682687982501-1e58ab814714?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MXwxfGFsbHwxfHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200")
    }
    
    func createdAt(currentImage: Int) -> Date? {
        createdAtExist = true
        return nil
    }
    
    func isLiked(currentImage: Int) -> Bool {
        isLikedIsDone = true
        return isLikedIsDone
    }
    
    func imageWidth(currentImage: Int) -> Double? {
        imageWidthGiven = true
        return 7831.0
    }
    
    func imageHeight(currentImage: Int) -> Double? {
        imageHeightGiven = true
        return 5221.0
    }
}
