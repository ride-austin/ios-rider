import Foundation
import RxCocoa
import RxSwift

final class AppCoordinator: Coordinator {
    
    private let navigationControllerDelegate = RANavigationControllerDelegate() //swiftlint:disable:this weak_delegate
    private let window: UIWindow
    private var unopenedDeepLink: (link: DeepLink, type: DeepLinkType, animated: Bool)?
    private var loginCoordinator: LoginCoordinator?
    private var mapCoordinator: MapCoordinator?
    private var sideMenuCoordinator: SideMenuCoordinator?
    private let navigationController: UINavigationController
    private let disposeBag = DisposeBag()
    private var fingerprintsCoordinator: FingerprintsCoordinator?

    // MARK: Coordinator
    let appContainer: AppContainer
    var rootViewController: UIViewController
    
    init(
        window: UIWindow,
        appContainer: AppContainer,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) {
        self.window = window
        self.appContainer = appContainer
        let root = FakeLaunchViewController(launchOptions: launchOptions)
        let nav = UINavigationController(rootViewController: root)
        nav.isNavigationBarHidden = true
        nav.delegate = navigationControllerDelegate
        self.rootViewController = nav
        self.navigationController = nav
        root.delegate = self
        
        //
        //  HACK: workaround for multiple 401 responses
        //
        let notificationName = NSNotification.Name(rawValue: "kDidSignoutNotification")
        NotificationCenter.default.rx.notification(notificationName)
            .throttle(2, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.handleSignout()
            })
            .disposed(by: disposeBag)
    }
    
    func setup() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    @discardableResult
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        guard appContainer.sessionManager.isSignedIn else {
            unopenedDeepLink = (deepLink, type, animated)
            showAlert(errorMessage: "Please login to continue")
            return false
        }
        
        var isHandled: Bool = false
        if let sideMenuCoordinator = sideMenuCoordinator {
            isHandled = sideMenuCoordinator.open(
                deepLink: deepLink,
                type: type,
                animated: animated
            )
        }
        
        guard isHandled == false else {
            unopenedDeepLink = nil
            return true
        }
        
        if let mapCoordinator = mapCoordinator {
            isHandled = mapCoordinator.open(
                deepLink: deepLink,
                type: type,
                animated: animated
            )
        }
        
        guard isHandled == false else {
            unopenedDeepLink = nil
            return true
        }
        
        unopenedDeepLink = (deepLink, type, animated)
        return false
        
    }
    
}

extension AppCoordinator {
    
    private func addLoginCoordinator() {
        loginCoordinator = LoginCoordinator(
            appContainer: appContainer,
            navigationController: navigationController
        )
        loginCoordinator?.delegate = self
        loginCoordinator?.setup()
    }
    
    private func addMapCoordinator() {
        mapCoordinator = MapCoordinator(
            appContainer: appContainer,
            navigationController: navigationController
        )
        sideMenuCoordinator = SideMenuCoordinator(
            appContainer: appContainer,
            navigationController: navigationController
        )
        sideMenuCoordinator?.mainCoordinator = mapCoordinator
        mapCoordinator?.sideMenuCoordinator = sideMenuCoordinator
        mapCoordinator?.setup()
        
        if let link = unopenedDeepLink {
            open(deepLink: link.link, type: link.type, animated: link.animated)
        }
    }
    
    private func handleSignIn() {
        addMapCoordinator()
    }
    
    @objc
    private func handleSignout() {
        RAPlaceSpotlightManager.cleanSearchIndex { }
        RAQuickActionsManager.cleanQuickActions()
        addLoginCoordinator()
    }
}

extension AppCoordinator {
    
    func registerPushToken() {
        guard
            appContainer.sessionManager.isSignedIn,
            let deviceTokenString = appContainer.deviceTokenString else { return }
        RATokensAPI.postToken(deviceTokenString) { _ in }
    }
    
}

extension AppCoordinator: LoginCoordinatorDelegate {
    
    func loginCoordinatorDidLoginSuccessfully(_ loginCoordinator: LoginCoordinator) {
        self.loginCoordinator = nil
        handleSignIn()
    }
    
    func loginCoordinatorDidRegisterSuccessfully(_ loginCoordinator: LoginCoordinator) {
        self.loginCoordinator = nil
        handleSignIn()
    }
    
}

extension AppCoordinator: FakeLaunchProtocol {
    
    func didFinishLaunching() {
        if appContainer.sessionManager.isSignedIn {
            registerPushToken()
            addMapCoordinator()
        }
        else {
            addLoginCoordinator()
        }
    }
    
}
