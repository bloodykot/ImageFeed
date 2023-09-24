//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 25.02.2024.
//
import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol & TabBarControllerProtocol {
    static var presenterTabBar: ImageFeed.ImagesListViewPresenterProtocol?
    var batchUpdatesCalled = false
    
    var presenter: ImagesListViewPresenterProtocol?
    
    func showLikeAlert(error: Error) {
        
    }
    
    func performBatchUpdates(oldCount: Int, newCount: Int) {
        batchUpdatesCalled = true
    }
    
}
