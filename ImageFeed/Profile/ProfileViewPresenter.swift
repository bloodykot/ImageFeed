//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 24.02.2024.
//

import Foundation
import WebKit


public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var nameLabel: String? { get set }
    var descriptionLabel: String? { get set }
    var loginNameLabel: String? { get set }
    
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func cleanTokenAndCookie()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    var testMode: Bool = false
    
    var nameLabel: String?
    var descriptionLabel: String?
    var loginNameLabel: String?
    
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileImageService = ProfileImageService.shared
    
    init(nameLabel: String?, descriptionLabel: String?, loginNameLabel: String?) {
        self.nameLabel = nameLabel
        self.descriptionLabel = descriptionLabel
        self.loginNameLabel = loginNameLabel
    }
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.updateAvatar(notification: notification)
            }
    }
    
    func viewWillAppear(_ animated: Bool) {
        fetchProfileInfo(useMockDataIn: testMode)
    }
    
    func fetchProfileInfo(useMockDataIn testMode: Bool) {
        if testMode {
            ProfileService.shared.fetchProfile(useMockDataIn: testMode) { _ in }
        }
        
        guard let profile = ProfileService.shared.profile else {
            assertionFailure("No saved profile")
            return
        }
        nameLabel = profile.name
        descriptionLabel = profile.bio
        loginNameLabel = profile.loginName
        
        profileImageService.fetchProfileImageURL(userName: profile.username, useMockDataIn: testMode) { _ in
            self.view?.setProfileInfo()
        }
    }
    
    func cleanTokenAndCookie() {
        OAuth2TokenStorage.shared.tokenReset()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func updateAvatar(notification: Notification) {
        guard
            view?.isViewLoaded() == true,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: url)
    }
    
}
