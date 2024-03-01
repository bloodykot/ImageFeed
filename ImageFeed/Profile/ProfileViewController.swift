import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func isViewLoaded() -> Bool
    func updateAvatar(url: URL)
    func setProfileInfo()
    func switchToSplashViewController()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    // MARK: - Public Properties
    var presenter: ProfileViewPresenterProtocol?
    var testMode: Bool = false
    
    // MARK: - Private Properties
    private var avatarImage: UIImage!
    private var avatarImageView: UIImageView!
    private(set) var nameLabel: UILabel!
    private(set) var loginNameLabel: UILabel!
    private(set) var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    private var logoutButtonImage: UIImage!
    private(set) var avatarURL: URL? = nil
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.ypBlack
        presenter?.viewDidLoad()
        
        setAvatar()
        setNameLabel()
        setLoginName()
        setDescriptionLabel()
        setLogoutButton()
        
        alertPresenter.delegate = self
        guard testMode == false else {
            viewWillAppear(true)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear(animated)
    }
    
    func isViewLoaded() -> Bool {
        return isViewLoaded
    }
    
    func setProfileInfo() {
        nameLabel.text = presenter?.nameLabel
        descriptionLabel.text = presenter?.descriptionLabel
        loginNameLabel.text = presenter?.loginNameLabel
    }
    
    func updateAvatar(url: URL) {
        guard testMode == false else {
            avatarURL = url
            return
        }
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
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        window.rootViewController = SplashViewController()
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
        nameLabel.accessibilityIdentifier = "nameLabel"
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
        loginNameLabel.accessibilityIdentifier = "loginNameLabel"
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
        logoutButton.accessibilityIdentifier = "logout button"
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
    
    private func showLogout() {
        alertPresenter.showAlertForLogout(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйдти?") { [weak self] in
                guard let self = self else { return }
                presenter?.cleanTokenAndCookie()
                switchToSplashViewController()
            }
    }
}

