//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 24.02.2024.
//

@testable import ImageFeed

import XCTest

final class ProfileViewTests: XCTestCase {
    func testCallsViewDidLoadAndViewWillAppear() {
        //given
        
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        profileViewController.testMode = true
        
        //when
        _ = profileViewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.theViewWillAppear)
    }
    
    func testPresenterCallsLoadProfileRequest() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(nameLabel: nil, descriptionLabel: nil, loginNameLabel: nil)
        presenter.testMode = true
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        presenter.viewWillAppear(true)
        
        //then
        XCTAssertTrue(viewController.viewIsLoaded)
        XCTAssertTrue(viewController.avatarUpdated)
        XCTAssertTrue(viewController.profileInfoSetted)
    }
    
    func testMockDataLoaded() {
        //given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenter(nameLabel: nil, descriptionLabel: nil, loginNameLabel: nil)
        presenter.testMode = true
        profileViewController.testMode = true
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        
        //when
        _ = profileViewController.view
        
        //then
        XCTAssertEqual(profileViewController.nameLabel.text, MockDataProfile().profile.name)
        XCTAssertEqual(profileViewController.descriptionLabel.text, MockDataProfile().profile.bio)
        XCTAssertEqual(profileViewController.loginNameLabel.text, MockDataProfile().profile.loginName)
        XCTAssertEqual(profileViewController.avatarURL, URL(string: MockDataProfile().urlString))
    }
}
