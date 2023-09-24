//
//  ImagesListViewControllerTest.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 25.02.2024.
//
@testable import ImageFeed

import XCTest

final class ImagesListTest: XCTestCase {
    func testCallsViewDidLoad() {
        //given
        
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        imagesListViewController.testMode = true
        
        //when
        _ = imagesListViewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.tableViewAnimatedIsUpdated)
        XCTAssertTrue(presenter.photosNextPageIsFetched)
    }
    
    func testPresenterCallsLoadProfileRequest() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter()
        presenter.testMode = true
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.batchUpdatesCalled)
    }
    
    func testImagesListViewPresenterFuncs() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter()
        presenter.testMode2 = true
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        presenter.updateTableViewAnimated()
        
        //then
        XCTAssertEqual(presenter.getPhotosCount(), 10)
        XCTAssertEqual(presenter.imageHeight(currentRow: 0), 5221.0)
        XCTAssertEqual(presenter.imageWidth(currentRow: 0), 7831.0)
        XCTAssertFalse(presenter.isLiked(currentRow: 0))
        XCTAssertEqual(presenter.thumbImageURL(currentRow: 0), URL(string: "https://images.unsplash.com/photo-1682687982501-1e58ab814714?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MXwxfGFsbHwxfHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200"))
    }
}
