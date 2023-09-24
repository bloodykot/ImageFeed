//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 23.02.2024.
//
import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    func setProgressValue( _ newValue: Float) {
        
    }
    func setProgressHidden( _ isHidden: Bool) {
        
    }
    
}
