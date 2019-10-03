import Foundation

protocol LoginCoordinatorDelegate: AnyObject {
    func loginCoordinatorDidLoginSuccessfully(_ loginCoordinator: LoginCoordinator)
    func loginCoordinatorDidRegisterSuccessfully(_ loginCoordinator: LoginCoordinator)
}

final class LoginCoordinator: Coordinator {

    // MARK: Coordinator
    let appContainer: AppContainer
    var rootViewController: UIViewController
    
    weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var splashViewController: SplashViewController?
    
    init(
        appContainer: AppContainer,
        navigationController: UINavigationController
        ) {
        self.appContainer = appContainer
        self.rootViewController = navigationController
        self.navigationController = navigationController
    }
    
    func setup() {
        if let splashVC = splashViewController {
            splashVC.delegate = self
            navigationController.setViewControllers([splashVC], animated: true)
        }
        else {
            let splashVC = SplashViewController()
            splashVC.delegate = self
            navigationController.setViewControllers([splashVC], animated: true)
            splashViewController = splashVC
        }
    }
    
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        return false
    }
    
}

extension LoginCoordinator {
    
    private func showLogin() {
        let vc = LoginViewController()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showRegister() {
        let vc = RegisterInfoViewController()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showForgotPassword() {
        let vc = ForgotPasswordViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showCreateProfile(phone: String, email: String, password: String) {
        guard let vc = CreateProfileViewController(
            email: email,
            mobile: phone,
            password: password
            ) else {
                assertionFailure("CreateProfileViewController cannot be  nil")
                return
        }
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension LoginCoordinator: SplashViewControllerDelegate {
    
    func splashViewControllerDidTapLogin(_ splashViewController: SplashViewController!) {
        showLogin()
    }
    
    func splashViewControllerDidTapRegister(_ splashViewController: SplashViewController!) {
        showRegister()
    }
    
}

extension LoginCoordinator: LoginViewControllerDelegate {
    
    func loginViewControllerDidLoginSuccessfully(_ loginViewController: LoginViewController!) {
        self.delegate?.loginCoordinatorDidLoginSuccessfully(self)
    }
    
    func loginViewControllerDidTapForgotPassword(_ loginViewController: LoginViewController!) {
        showForgotPassword()
    }
    
}

extension LoginCoordinator: RegisterInfoViewControllerDelegate {
    
    func registerInfoViewControllerDidRegisterSuccessfully(withFacebook registerInfoViewController: RegisterInfoViewController!) {
        delegate?.loginCoordinatorDidRegisterSuccessfully(self)
    }
    
    func registerInfoViewControllerDidVerify(_ phone: String!, email: String!, password: String!) {
        showCreateProfile(
            phone: phone,
            email: email,
            password: password
        )
    }
    
}

extension LoginCoordinator: CreateProfileViewControllerDelegate {
    
    func createProfileViewControllerDidRegisterSuccessfully(_ createProfileViewController: CreateProfileViewController!) {
        delegate?.loginCoordinatorDidRegisterSuccessfully(self)
    }
    
}
