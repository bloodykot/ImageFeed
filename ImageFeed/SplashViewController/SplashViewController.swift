import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let alertPresenter = AlertPresenter()
    private let profileImageService = ProfileImageService.shared
    private var splashLogoImage: UIImage!
    private var splashLogoImageView: UIImageView!

    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        view.backgroundColor = Constants.ypBlack
        setUpSplashLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func switchToAuthViewController() {
        guard let authViewController = UIStoryboard(
            name: "Main",
            bundle: nil)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func checkAuthStatus() {
        if oauth2Service.isAuthenticated {
            UIBlockingProgressHUD.show()
            fetchProfile()
        } else {
            switchToAuthViewController()
        }
    }
}

extension SplashViewController {
    private func setUpSplashLogo() {
        splashLogoImage = UIImage(named: "splash_screen_logo")
        splashLogoImageView = UIImageView(image: splashLogoImage)
        view.addSubview(splashLogoImageView)
        splashLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashLogoImageView.heightAnchor.constraint(equalToConstant: 77.68),
            splashLogoImageView.widthAnchor.constraint(equalToConstant: 75),
            splashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) { 
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.fetchProfile()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLoginAlert(error: error)
                break
            }
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile { [weak self] profileResult in
            switch profileResult {
            case .success(_):
                UIBlockingProgressHUD.dismiss()
                guard let username = self?.profileService.profile?.username else { return }
                self?.profileImageService.fetchProfileImageURL(userName: username) { _ in }
                self?.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self?.showLoginAlert(error: error)
            }
        }
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему, \(error.localizedDescription)") { [weak self] in
                self?.switchToAuthViewController()
            }
    }
}
