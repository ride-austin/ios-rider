import Foundation

protocol Coordinator: AnyObject {
    var rootViewController: UIViewController { get }
    func setup()
    @discardableResult
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool
}

extension Coordinator {
    
    func showAlert(errorMessage: String) {
        let alert = UIAlertController(
            title: "Oops",
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default
        ))
        rootViewController.present(alert, animated: true)
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default
        ))
        rootViewController.present(alert, animated: true)
    }
    
}
