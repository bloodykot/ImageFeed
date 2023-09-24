//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dmitry Kirdin on 24.02.2024.
//
import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var viewIsLoaded: Bool = false
    var avatarUpdated: Bool = false
    var profileInfoSetted: Bool = false
    var splashViewControllerInitiated: Bool = false
    
    
    func viewDidLoad() {
        presenter?.viewDidLoad()
    }
    
    func viewWillAppear(_ animated: Bool) {
        presenter?.viewWillAppear(animated)
    }
    
    func isViewLoaded() -> Bool {
        viewIsLoaded = true
        return true
    }
    
    func updateAvatar(url: URL) {
        avatarUpdated = true
    }
    
    func setProfileInfo() {
        profileInfoSetted = true
        
    }
    
    func switchToSplashViewController() {
        splashViewControllerInitiated = true
    }
    
}
