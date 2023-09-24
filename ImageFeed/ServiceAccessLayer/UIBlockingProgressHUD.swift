import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    // MARK: - Public Properties
    static var isShowing: Bool = false
    
    // MARK: - Private Properties
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first 
        else {
            return nil
        }
        
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Public Methods
    static func show() {
        isShowing = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        isShowing = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
