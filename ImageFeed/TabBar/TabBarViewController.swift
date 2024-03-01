import UIKit
public protocol TabBarControllerProtocol {
    static var presenterTabBar: ImagesListViewPresenterProtocol? { get }
}

final class TabBarController: UITabBarController & TabBarControllerProtocol {
    static var presenterTabBar: ImagesListViewPresenterProtocol? = ImagesListViewPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
                
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController")
               
        self.viewControllers = [imagesListViewController, profileViewController]
        
        // MARK: 13 sprint
        let profileViewPresenter = ProfileViewPresenter(
            nameLabel: nil,
            descriptionLabel: nil,
            loginNameLabel: nil)
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
    }
}
