import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?
    
    func showAlert(
        title: String,
        message: String,
        handler: @escaping ()-> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "OK", style: .default) { _ in
            handler()
        }
        alert.addAction(alertAction)
        delegate?.present(alert, animated: true)
    }
    
    func showAlertForLargeImage(
        title: String,
        message: String,
        handler: @escaping ()-> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "Повторить", style: .default) { _ in
            handler()
        }
        let alertAction2 = UIAlertAction(
            title: "Не надо",
            style: .cancel)
            
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        delegate?.present(alert, animated: true)
    }
    
    func showAlertForLogout(
        title: String,
        message: String,
        handler: @escaping ()-> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "Да", style: .default) { _ in
            handler()
        }
        let alertAction2 = UIAlertAction(
            title: "Нет",
            style: .cancel)
            
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        delegate?.present(alert, animated: true)
    }
}
