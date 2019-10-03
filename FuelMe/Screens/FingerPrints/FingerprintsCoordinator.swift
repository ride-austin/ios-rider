import UIKit

@objc protocol FingerprintsCoordinatorDelegate: AnyObject {
    func didTapNotNow()
    func didFinishSuccessfully()
}

@objc final class FingerprintsCoordinator: NSObject & Coordinator {
    
    weak var delegate: FingerprintsCoordinatorDelegate?
    
    // MARK: Public
    let appContainer: AppContainer
    let rootViewController: UIViewController
    
    // MARK: Private
    private let driverId: Int
    private let primaryNavigationController: UINavigationController
    private var secondaryNavigationController: UINavigationController
    
     // MARK: Public
    init(
        appContainer: AppContainer,
        driverId: Int,
        navigationController: UINavigationController
        ) {
        self.appContainer = appContainer
        self.driverId = driverId
        self.rootViewController = navigationController
        self.primaryNavigationController = navigationController
        self.secondaryNavigationController = UINavigationController()
    }
    
    func setup() {
        let fingerprintController = FingerprintsViewController(delegate: self)
        fingerprintController.title = "Fingerprints"
        secondaryNavigationController.setViewControllers([fingerprintController], animated: false)
        secondaryNavigationController.modalPresentationStyle = .fullScreen
        primaryNavigationController.present(secondaryNavigationController, animated: true)
    }
    
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        return false
    }
}

extension FingerprintsCoordinator: FingerprintsViewControllerDelegate {
    
    func didTapPayment(_: FingerprintsViewController) {
        let paymentVC: PaymentViewController = PaymentViewController()
        secondaryNavigationController.pushViewController(paymentVC, animated: true)
    }
    
    func didTapSubmit(_: FingerprintsViewController) {
        showHUD()
        RADriverAPI.postCheckrPayment(withDriverId: String(driverId)) { [weak self] (_, error) in
            self?.hideHUD()
            if let error = error {
                RAAlertManager.showError(with: error as RAAlertItem, andOptions: RAAlertOption(state: .StateAll, andShownOption: .AllowNetworkError))
            }
            else {
                self?.primaryNavigationController.dismiss(animated: true)
                self?.delegate?.didFinishSuccessfully()
            }
        }
    }
    
    func didTapNotNow(_: FingerprintsViewController) {
        primaryNavigationController.dismiss(animated: true)
        delegate?.didTapNotNow()
    }
    
    func didTapContactSupport(_: FingerprintsViewController) {
        let messageVC = SMessageViewController()
        secondaryNavigationController.pushViewController(messageVC, animated: true)
    }
}
