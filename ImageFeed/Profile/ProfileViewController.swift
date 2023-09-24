import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var avatarImage: UIImage!
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    private var logoutButtonImage: UIImage!
    private let profileService = ProfileService.shared
    private let oAuth2Token = OAuth2TokenStorage.shared.token!
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.ypBlack
        setAvatar()
        setNameLabel()
        setLoginName()
        setDescriptionLabel()
        setLogoutButton()
        
        alertPresenter.delegate = self
        
        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.updateAvatar(notification: notification)
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = ProfileService.shared.profile else {
            assertionFailure("No saved profile")
            return
        }
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
        loginNameLabel.text = profile.loginName
        
        profileImageService.fetchProfileImageURL(userName: profile.username) { _ in
            //no completion
        }
    }
    
    // MARK: - Private Methods
    private func setAvatar() {
        avatarImage = UIImage(named: "avatar_placeholder")
        avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.backgroundColor = .clear
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        view.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.textColor = .white
        nameLabel.font = UIFont(name: "System", size: 23)
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func setLoginName() {
        loginNameLabel = UILabel()
        loginNameLabel.text = ""
        loginNameLabel.font = UIFont(name: "System", size: 13)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = Constants.ypGrey
        view.addSubview(loginNameLabel)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func setDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.text = ""
        descriptionLabel.font = UIFont(name: "System", size: 13)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func setLogoutButton() {
        logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(self.didTapLogoutButton)
        )
        logoutButton.tintColor = Constants.ypRed
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: avatarImageView.trailingAnchor, constant: 0),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        showLogout()
    }
    
    //@objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        updateAvatar(url: url)
    }
    
    private func updateAvatar(url: URL) {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        avatarImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "avatar_placeholder"),
            options: [.processor(processor)])
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    //MARK: 12 sprint
    private func showLogout() {
        alertPresenter.showAlertForLogout(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйдти?") { [weak self] in
                guard let self = self else { return }
                OAuth2TokenStorage.shared.tokenReset()
                HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
                switchToSplashViewController()
            }
    }
}

