import Appirater
import Branch
import CoreSpotlight
import FBSDKCoreKit
import FBSDKLoginKit
import Foundation
import GooglePlaces
import GoogleMaps
import Firebase
import UserNotificationsUI

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appContainer: AppContainer!
    var appCoordinator: AppCoordinator!
    var deviceTokenString: String?
    var launchUrl: URL?
    
    @objc func registerForNotifications() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RAEnvironmentManager.shared()
        setupThirdParty()
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                if let params = params as? [String: AnyObject] {
                    if let clickedBranchedLink = params["+clicked_branch_link"] as? Bool {
                        if clickedBranchedLink {
                            PersistenceManager.saveBranchParams(params)

                        }
                    }
                }
            }
        })
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.appContainer = AppContainer()
        self.appCoordinator = AppCoordinator(
            window: window,
            appContainer: appContainer,
            launchOptions: launchOptions
        )
        appCoordinator.setup()
        
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            self.launchUrl = url
        }
       
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        RASessionManager.shared().saveContext() //Save all session data.
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        ConfigurationManager.needsReload()
        if RASessionManager.shared().isSignedIn {
            RASessionManager.shared().reloadCurrentRider(completion: nil)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        UIApplication.shared.isIdleTimerDisabled = true
        if let url = launchUrl, let deepLink = appContainer?.deepLinkService.parse(url: url) {
            appCoordinator?.open(deepLink: deepLink, type: .url, animated: false)
            launchUrl = nil
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        RASessionManager.shared().saveContext() //Save all session data
    }
    
    // MARK: - Notifications
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        RAAlertManager.showAlert(
            withTitle: "Message",
            message: notification.alertBody,
            options: RAAlertOption(shownOption: .Overlap)
        )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushNotificationSplitFareManager.didReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        executeInRealDevice {
            let appName = "RideAustin"
            let message: NSString = "We are unable to register your device for push notifications! Please check your notification settings for \(appName)." as NSString
            RAAlertManager.showError(with: message, andOptions: RAAlertOption(state: .StateActive))
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        appContainer.deviceTokenString = tokenParts.joined()
        appCoordinator.registerPushToken()
    }
    
    // MARK: - External Handlers
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        let annotation = options[.annotation]
        
        if ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
            ) {
            return true
        }
        else if let isHandledByBranch = Branch.getInstance()?.application(
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
            ), isHandledByBranch {
            return true
        }
        else if let deepLink = appContainer?.deepLinkService.parse(url: url) {
            return appCoordinator?.open(deepLink: deepLink, type: .url, animated: false) ?? false
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        
        if userActivity.activityType == CSSearchableItemActionType,
            let searchIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                RAPlaceSearchManager.sharedInstance().processSearchIndex(searchIdentifier)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        RAPlaceSearchManager.sharedInstance().processSearchIndex(shortcutItem.type)
        completionHandler(true)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    }
    
}

extension AppDelegate {
    
    private func setupThirdParty() {
        Appirater.setAppId("1116489847")
        setupGoogle()
    }
    
    private func setupGoogle() {
        GMSPlacesClient.provideAPIKey(AppConfig.googleMapKey())
        GMSServices.provideAPIKey(AppConfig.googleMapKey())
        GMSServices.provideAPIOptions(["B3MWHUG2MR0DQW"])
        Messaging.messaging().delegate = self // need to be set before FirebaseApp.configure()
        executeInRelease {
            FirebaseApp.configure()
        }
        Analytics.setUserProperty(Bundle.completeVersion(), forName: "version_and_build")
    }
    
    @objc
    private func openDeepLink(notification: NSNotification) {
        if let deepLink = notification.userInfo?["deepLink"] as? DeepLink {
            appCoordinator.open(
                deepLink: deepLink,
                type: .notificationCenter,
                animated: false
            )
        }
    }
    
}
