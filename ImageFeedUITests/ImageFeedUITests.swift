//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Dmitry Kirdin on 26.02.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("*****")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            
        passwordTextField.tap()
        
        sleep(3)
        
        passwordTextField.tap()
        
        sleep(3)
        
        passwordTextField.typeText("*****")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
            
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
            
        sleep(3)
            
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
            
        cellToLike.buttons["like button"].tap()
        
        sleep(5)
        
        cellToLike.buttons["like button"].tap()
            
        sleep(3)
            
        cellToLike.tap()
            
        sleep(3)
            
        let image = app.scrollViews.images.element(boundBy: 0)
            
        image.pinch(withScale: 3, velocity: 1)
            
        image.pinch(withScale: 0.5, velocity: -1)
            
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["Dima Kirdin"].exists)
        XCTAssertTrue(app.staticTexts["@bloodykot"].exists)
            
        app.buttons["logout button"].tap()
            
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
            
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
        
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }
    
}
