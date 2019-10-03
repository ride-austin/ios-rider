import UIKit

final class PermissionsCoordinator {
    
    private var window: UIWindow?

    init() {
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func showLocationAlert() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = LocationAlertViewController(delegate: self)
        window?.rootViewController = vc
        window?.isHidden = false
    }
    
    // MARK: Private
    
    private func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthorizationStatusChanged),
            name: NSNotification.Name(rawValue: kLocationAuthorizationStatusChanged),
            object: nil
        )
    }
    
    @objc
    private func handleAuthorizationStatusChanged() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            showLocationAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            hideLocationAlert()
        }
    }
    
    private func hideLocationAlert() {
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
    }
    
    private func openLocationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
            CLLocationManager.authorizationStatus() == .denied,
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
}

extension PermissionsCoordinator: LocationAlertViewControllerDelegate {
    
    func locationAlertViewControllerDidConfirm(_: LocationAlertViewController) {
        openLocationSettings()
        hideLocationAlert()
    }
    
    func locationAlertViewControllerDidCancel(_: LocationAlertViewController) {
        hideLocationAlert()
    }
    
}
