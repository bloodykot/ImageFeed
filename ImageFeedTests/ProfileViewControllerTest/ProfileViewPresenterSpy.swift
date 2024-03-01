//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 24.02.2024.
//
import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var theViewWillAppear: Bool = false
    var cleanTokenAndCookies: Bool = false
    var view: ProfileViewControllerProtocol?
    var nameLabel: String?
    var descriptionLabel: String?
    var loginNameLabel: String?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func viewWillAppear(_ animated: Bool) {
        theViewWillAppear = true
    }
    func cleanTokenAndCookie() {
        cleanTokenAndCookies = true
    }
}
