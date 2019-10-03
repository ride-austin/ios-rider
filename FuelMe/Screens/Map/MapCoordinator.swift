import Foundation
import Pulley

final class MapCoordinator: Coordinator {

    // MARK: Public
    
    weak var sideMenuCoordinator: SideMenuCoordinator?
    var appContainer: AppContainer
    var rootViewController: UIViewController
    
    // MARK: Private
    
    private let navigationController: UINavigationController
    private let campaignNavigationController: UINavigationController = UINavigationController()
    private let messageController: RAMessageController
    private let imageViewAnimator: BFRImageTransitionAnimator = BFRImageTransitionAnimator()
    private var global: ConfigGlobal {
        return ConfigurationManager.shared().global
    }
    private var rideManager: RARideManager {
        return RARideManager.shared()
    }
    private var sessionManager: RASessionManager {
        return appContainer.sessionManager
    }
    private var environmentManager: RAEnvironmentManager {
        return RAEnvironmentManager.shared()
    }
    
    // MARK: Public
    
    init(
        appContainer: AppContainer,
        navigationController: UINavigationController
        ) {
        self.appContainer = appContainer
        self.rootViewController = navigationController //should be LocationViewController
        self.navigationController = navigationController
        self.messageController = RAMessageController(navigationController: navigationController)
    }
    
    // MARK: Coordinator
    
    func setup() {
        willInitMapScreen()
        let vc = LocationViewController()
        vc.mainCoordinator = self
        vc.sideMenuCoordinator = sideMenuCoordinator
        sideMenuCoordinator?.femaleDriverViewDelegate = vc
        if let delegate = vc as? SplitFarePushDelegate {
            SplitFareManager.shared().delegate = delegate
        }
        rootViewController = vc
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        guard let deepLink = deepLink as? MapDeepLink else { return false }
        switch deepLink {
        case .requestToken(let token):
            rideManager.initiateThirdPartyRide(fromQueueToken: token, completion: { [weak self] (ride, error) in
                if let ride = ride {
                    if let vc = self?.rootViewController as? LocationViewController {
                        vc.performRideStatusChanged(to: ride.status)
                    }
                    else {
                        assertionFailure("Expecting LocationViewController")
                    }
                }
                else {
                    self?.navigate(toError: error)
                }
            })
            return true
        }
    }
    
    // MARK: Private
    
    private func willInitMapScreen() {
        setCrashlyticsUser()
        setBugfenderUser()
        LocationService.shared().start()
        sideMenuCoordinator?.checkLocationPermissions()
        ConfigurationManager.checkConfigurationBased(on: LocationService.shared().myLocation)
        RAPlaceSpotlightManager.setupSearchIndex()
        RAQuickActionsManager.setupQuickActions()
    }
    
    private func setCrashlyticsUser() {
        let user = sessionManager.currentUser
        Crashlytics.sharedInstance().setUserIdentifier(user?.riderID()?.stringValue)
        Crashlytics.sharedInstance().setUserEmail(user?.email)
        Crashlytics.sharedInstance().setUserName(user?.fullName)
    }
    
    private func setBugfenderUser() {
        let user = sessionManager.currentUser
        let id = user?.riderID()?.stringValue ?? "Unknown"
        let email = user?.email ?? "Unknown"
        let fullName = user?.fullName ?? "Unknown"
        Bugfender.setDeviceString(id, forKey: "RIDER_ID")
        Bugfender.setDeviceString(email, forKey: "EMAIL")
        Bugfender.setDeviceString(fullName, forKey: "FULLNAME")
    }
    
    // MARK: Navigation
    
    private func showActivityViewController(with items: [Any], sender: UIButton) {
        SVProgressHUD.show(withStatus: "PLEASE WAIT...")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let popoverPresentationController = avc.popoverPresentationController {
                popoverPresentationController.sourceView = sender
                popoverPresentationController.sourceRect = sender.bounds
            }
            DispatchQueue.main.async { [weak self] in
                SVProgressHUD.dismiss()
                self?.navigationController.present(avc, animated: true, completion: nil)
            }
        }
    }
    
    private func showCampaignDetail(campaignDetail: RACampaignDetail, providerCampaigns: [RACampaignDetail]? = nil) {
        sideMenuCoordinator?.campaignCoordinator?.setupWithList(providerCampaigns: [campaignDetail])
    }
    
    private func showContactDeafDriver(_ driver: RADriverDataModel, maskedContactNumber: String) {
        let vc = UIStoryboard(name: "Overlays", bundle: nil).instantiateViewController(withIdentifier: RAContactViewController.className()) as! RAContactViewController //swiftlint:disable:this force_cast
        vc.driverFirstName = driver.user.displayName() ?? ""
        vc.didTapSMSBlock = {
            RAContactHelper.performSMS(maskedContactNumber)
        }
        vc.modalPresentationStyle = .currentContext
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    private func showContactDriver(maskedContactNumber: String, sender: UIButton) {
        let alert = UIAlertController(
            title: nil,
            message: "How do you want to contact your driver",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "CALL",
            style: .default,
            handler: { _ in
                RAContactHelper.performCall(maskedContactNumber)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "SMS",
            style: .default,
            handler: { _ in
                RAContactHelper.performSMS(maskedContactNumber)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        if let popoverPresentationController = alert.popoverPresentationController {
            alert.message = alert.message ?? "" + "\n\(maskedContactNumber)"
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        navigationController.present(alert, animated: true, completion: nil)
    }
    
    private func showFeedbackForm(ride: RARideDataModel) {
        let vc = UIStoryboard(name: "Overlays", bundle: nil).instantiateViewController(withIdentifier: CFFormViewController.className()) as! CFFormViewController //swiftlint:disable:this force_cast
        vc.setRide(ride)
        navigationController.present(vc, animated: true, completion: nil)
    }
    
}

extension MapCoordinator: LFlowControllerProtocol {
    
    func navigateToRoundUp() {
        sideMenuCoordinator?.showRoundUpVC()
    }
    
    func navigate(toContactDriver driver: RADriverDataModel?, sender: UIButton) {
        guard let driver = driver,
              let contactNumber = driver.phoneNumber else { return }
        
        let characterSet = NSCharacterSet.decimalDigits.inverted
        let cleanContactNumber = contactNumber.components(separatedBy: characterSet).joined()
        let maskedContactNumber =  RAContactHelper.maskContactNumber(withDirectConnectIfNeeded: cleanContactNumber)
        if driver.isDeaf {
            showContactDeafDriver(driver, maskedContactNumber: maskedContactNumber)
        }
        else {
            showContactDriver(maskedContactNumber: maskedContactNumber, sender: sender)
        }
    }
    
    func navigateToGetFeedback(forRide ride: RARideDataModel?, orError error: Error?) {
        if let ride = ride {
            guard ride.isRiding == false else { return }
            let message: String
            if let cancellationFee = ride.cancellationFee, cancellationFee.doubleValue > 0 {
                message = String(format: "Your ride is cancelled. You've been charged a $%.2f cancellation fee.", cancellationFee.doubleValue)
            }
            else {
                message = "Your ride is cancelled"
            }
            
            let cancellationFeedback = global.cancellationFeedback
            if let driverAcceptedDate = ride.driverAcceptedDate, cancellationFeedback?.shouldShowForRide(withAcceptedDate: driverAcceptedDate) == true {
                showFeedbackForm(ride: ride)
                if ride.cancellationFee != nil {
                    let option = RAAlertOption(shownOption: .Overlap)
                    RAAlertManager.showAlert(withTitle: "", message: message, options: option)
                }
            }
            else {
                let option = RAAlertOption(shownOption: .Overlap)
                RAAlertManager.showAlert(withTitle: "", message: message, options: option)
            }
        }
        else {
            navigate(toError: error)
        }
    }
    
    func navigateToPaymentMethodList() {
        sideMenuCoordinator?.showPaymentFlow()
    }
    
    //duplicates SideMenuCoordinator
    func navigate(toError error: Any?) {
        guard let error = error as? RAAlertItem else {
            assertionFailure("Expecting RAAlertItem")
            return
        }
        RAAlertManager.showError(with: error, andOptions: RAAlertOption(shownOption: .AllowNetworkError))
    }
    
}

extension MapCoordinator: DiscountDetailNavigationProtocol {

    func navigateToCampaignDetail(withID campaignID: NSNumber) {
        SVProgressHUD.show(withStatus: "PLEASE WAIT...")
        RACampaignAPI.getCampaignWithID(campaignID, withCompletion: { [weak self] (campaign, error) in
            SVProgressHUD.dismiss()
            if let campaign = campaign {
                self?.showCampaignDetail(campaignDetail: campaign)
            }
            else {
                self?.navigate(toError: error)
            }
        })
    }

}

extension MapCoordinator: RequestRideViewNavigationProtocol {
    
    func navigateToPromotions() {
        sideMenuCoordinator?.showPromoVC()
    }
    
}

extension MapCoordinator: DriverInfoViewNavigationProtocol {
    
    func navigateToSplitFare() {
        // RA-12576 Payment Providers like Bevo Pay doesn't allow splitfare
        // should use paymentProvider here
        if let config = global.ut?.payWithBevoBucks,
            config.availableForSplitfare == false,
            sessionManager.currentRider?.preferredPaymentMethod == PaymentMethod.bevoBucks {
            RAAlertManager.showAlert(withTitle: "", message: config.splitfareMessage)
        }
        else {
            guard let rideId = rideManager.currentRide?.modelID else { return }
            let vc = UIStoryboard(name: SplitFareViewController.className(), bundle: nil).instantiateViewController(withIdentifier: SplitFareViewController.className()) as! SplitFareViewController //swiftlint:disable:this force_cast
            vc.rideId = rideId.stringValue
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToFullscreen(from imageView: UIImageView, withOriginalFrame originalFrame: CGRect) {
        guard let image = imageView.image else { return }
        imageViewAnimator.animatedImageContainer = imageView
        imageViewAnimator.animatedImage = image
        imageViewAnimator.imageOriginFrame = originalFrame
        imageViewAnimator.desiredContentMode = imageView.contentMode
        
        guard let imageVC = BFRImageViewController(imageSource: [image]) else { return }
        imageVC.transitioningDelegate = imageViewAnimator
        imageVC.enableDoneButton = false
        navigationController.topViewController?.present(imageVC, animated: true, completion: nil)
    }
    
    func navigateToShareETA(withSender sender: UIButton) {
        guard let rideId = rideManager.currentRide?.modelID else { return }
        SVProgressHUD.show(withStatus: "PLEASE WAIT...")
        sender.isEnabled = false
        RARideAPI.getRealTimeTrackingToken(byID: rideId.stringValue, completion: { [weak self] (token, error) in
            if let token = token {
                guard let strongSelf = self else { return }
                let env = strongSelf.environmentManager.environmentQueryForRealTimeTracking()
                let link = "http://www.rideaustin.com/real-time-tracking?id=\(token)\(env)"
                let message = "I'm on my way!\nCheckout my Ride and Live ETA here: \(link)"
                let liveETAItem = LiveETAProvider(placeholderItem: [String: Any]())
                liveETAItem.subject = message
                liveETAItem.message = message
                self?.showActivityViewController(with: [liveETAItem], sender: sender)
            }
            else {
                SVProgressHUD.dismiss()
                self?.navigate(toError: error)
            }
            sender.isEnabled = true
        })
    }
}

extension MapCoordinator: MessageFlowControllerProtocol {
    
    func showCampaignMessage(_ campaign: RACampaign!, in viewController: UIViewController & InsertingProtocol) {
        messageController.showCampaignMessage(campaign, in: viewController) { [weak self] in
            self?.navigateToCampaignDetail(withID: campaign.modelID)
        }
    }
    
    func hideCampaignMessage() {
        messageController.hideCampaignMessage()
    }
    
    func showStackedRideInfo(in viewController: UIViewController & InsertingProtocol) {
        messageController.showStackedRideInfo(in: viewController)
    }
    
    func hideStackedRideInfo() {
        messageController.hideStackedRideInfo()
    }
    
    func showPaymentDeficiency(in viewController: UIViewController & InsertingProtocol) {
        guard rideManager.isRiding == false else {
            messageController.hidePaymentDeficiencyMessage()
            return
        }
        
        guard let rider = sessionManager.currentRider else { return }
        guard rider.user.active else { return }
        let noCardMessage = "Save a payment method to start riding"
        func messageTapped() {
            navigateToPaymentMethodList()
        }
        
        if rider.unpaidBalance != nil {
            let message = global.unpaidBalance?.warningMessage ?? "Check Pending Balance"
            messageController.showPaymentDeficiencyMessage(
                message,
                in: viewController,
                didTap: messageTapped
            )
        }
        else if ApplePayHelper.hasApplePaySetup() && rider.preferredPaymentMethod == PaymentMethod.applePay {
            messageController.hidePaymentDeficiencyMessage()
        }
        else if rider.hasPrimaryCard() {
            if rider.primaryCard().cardExpired.boolValue {
                messageController.showPaymentDeficiencyMessage(
                    noCardMessage,
                    in: viewController,
                    didTap: messageTapped
                )
            }
            else {
                messageController.hidePaymentDeficiencyMessage()
            }
        }
        else if rider.hasPrimaryCard() == false {
            messageController.showPaymentDeficiencyMessage(
                noCardMessage,
                in: viewController,
                didTap: messageTapped
            )
        }
    }
    
}
