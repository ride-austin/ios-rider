import Foundation

final class SideMenuCoordinator: NSObject, Coordinator {
    
    struct Item {
        let title: String
        let iconName: String?
        let iconUrl: URL?
        let iconColor: UIColor?
        let didTapBlock: ((UITableViewCell) -> Void)?
        
        init(
            title: String,
            iconName: String? = nil,
            iconUrl: URL? = nil,
            iconColor: UIColor? = nil,
            didTapBlock: ((UITableViewCell) -> Void)? = nil
        ) {
            self.title = title
            self.iconName = iconName
            self.iconUrl = iconUrl
            self.iconColor = iconColor
            self.didTapBlock = didTapBlock
        }
    }
    
    // MARK: Coordinator
    
    let appContainer: AppContainer
    lazy var campaignCoordinator: CampaignCoordinator? = {
        return CampaignCoordinator(
            appContainer: appContainer,
            navigationController: navigationController
        )
    }()
    var rootViewController: UIViewController
    
    weak var mainCoordinator: DiscountDetailNavigationProtocol?
    weak var femaleDriverViewDelegate: WomanOnlyViewDelegate?
    var permissionsCoordinator: PermissionsCoordinator = PermissionsCoordinator()
    
    private var driverSignUpCoordinator: DSFlowController?
    private let navigationController: UINavigationController
    private lazy var menu: VKSideMenu = {
        let view = VKSideMenu(width: 278, andDirection: .leftToRight)
        view.dataSource = self
        view.delegate = self
        view.enableOverlay = true
        view.hideOnSelection = true
        view.selectionColor = UIColor.azureBlue()
        view.iconsColor = UIColor.azureBlue()
        view.textColor = .white
        return view
    }()
    private var menuItems: [Item]
    private var global: ConfigGlobal {
        return ConfigurationManager.shared().global
    }
    private var currentRider: RARiderDataModel? {
        return RASessionManager.shared().currentRider
    }
    private var rideManager: RARideManager {
        return RARideManager.shared()
    }
    private var headerView: RASideMenuHeaderView?
    private var fingerprintsCoordinator: FingerprintsCoordinator?
    init(
        appContainer: AppContainer,
        navigationController: UINavigationController
        ) {
        self.appContainer = appContainer
        self.rootViewController = navigationController
        self.navigationController = navigationController
        self.menuItems = []
        super.init()
        setupObservers()
        updateMenuItemsWithConfig(global: global, rider: currentRider)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        
    }
    
    @discardableResult
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        switch deepLink {
        case let deepLink as SideMenuDeepLink:
            switch deepLink {
            case .driverSignup:
                showDriverSignup()
                return true
                
            case .editProfile:
                showEditProfileVC()
                return true
                
            case .rateRide(let rideId):
                showRatingViewWithRideId(rideId: rideId)
                return true
                
            case .tripHistory:
                showTripHistoryVC()
                return true
            }
            
        default:
            return false
        }
    }
    
    @discardableResult
    func checkLocationPermissions() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            permissionsCoordinator.showLocationAlert()
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted:
            return false
        }
    }
    
    // MARK: Private
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenu),
            name: NSNotification.Name("kNotificationDidChangeConfiguration"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenu),
            name: NSNotification.Name("kNotificationDidUpdateCurrentRider"),
            object: nil)
    }
    
    @objc
    private func updateMenu() {
        updateMenuItemsWithConfig(global: global, rider: currentRider)
        menu.tableView?.reloadData()
    }
    
    private func updateMenuItemsWithConfig(global: ConfigGlobal, rider: RARiderDataModel?) {
        menuItems.removeAll()
        guard let rider = rider else { return }
        if rider.user.active {
            
            menuItems += [
                Item(
                    title: "Payment",
                    iconName: "payment-icon-active",
                    didTapBlock: { [weak self] _ in
                        self?.showPaymentFlow()
                    }
                ),
                Item(
                    title: "Round Up",
                    iconName: "donate",
                    didTapBlock: { [weak self] _ in
                        self?.showRoundUpVC()
                    }
                ),
                Item(
                    title: "Trip History / Support",
                    iconName: "history-icon-active",
                    didTapBlock: { [weak self] _ in
                        self?.showTripHistoryVC()
                    }
                )
            ]
            
            if let isEnabled = global.configDirectConnect?.isEnabled, isEnabled {
                menuItems.append(Item(
                    title: "Direct Connect",
                    iconName: "direct-connect-icon",
                    didTapBlock: attemptToShowDirectConnectVC
                ))
            }
            
            menuItems.append(Item(
                title: "Promotions",
                iconName: "star",
                didTapBlock: attemptToShowPromotionsVC
            ))
            
            if DSFlowController.shouldShowInMenu(for: rider.user) {
                menuItems.append(Item(
                    title: "Drive with \(ConfigurationManager.appName())",
                    iconName: "drive-with-icon-active",
                    didTapBlock: showDriverSignup
                ))
            }
            
            if let providers = global.campaignProviders {
                let items = providers.map { (provider) -> Item in
                    Item(
                        title: provider.menuTitle,
                        iconUrl: provider.menuIcon,
                        didTapBlock: { [weak self] _ in
                            self?.showCampaignProvider(provider)
                        }
                    )
                }
                menuItems += items
            }
        }
        
        if let acDriver = global.accessibleDriver, acDriver.isEnabled {
            menuItems.append(Item(
                title: "Accessibility",
                iconName: "menuWheelChair",
                didTapBlock: { [weak self] cell in
                    self?.showAccessibilityDriver(cell, acDriver)
                }
            ))
        }
        
        if let femaleDriverType = global.womanOnly() {
            menuItems.append(Item(
                title: femaleDriverType.displayTitle ?? "Female Driver Mode",
                iconName: "icon-pink-drivers",
                iconColor: UIColor.femaleDriverPink(),
                didTapBlock: attemptToShowFemaleDriverVC
            ))
        }
        
        if let fingerprintedDrivers = global.fingerprintedDrivers() {
            menuItems.append(Item(
                title: fingerprintedDrivers.menuTitle ?? "Fingerprinted Drivers",
                iconUrl: fingerprintedDrivers.iconUrl,
                didTapBlock: { [weak self] _ in
                    self?.showFingerprintedDrivers(model: fingerprintedDrivers)
                }
            ))
        }
        
        menuItems.append(Item(
            title: "Settings",
            iconName: "settings-icon-active",
            didTapBlock: showSettingsVC
        ))
    }

    // MARK: Navigation
    
    private func attemptToShowDirectConnectVC(_: UITableViewCell? = nil) {
        switch rideManager.status {
        case .unknown,
             .none,
             .prepared,
             .noAvailableDriver,
             .riderCancelled,
             .driverCancelled,
             .adminCancelled,
             .completed:
            showDirectConnectInputVC()
            
        case .requesting,
             .requested,
             .driverAssigned,
             .driverReached,
             .active:
            showAlert(message: "You may use direct connect after the trip.")
        }
    }
    
    private func attemptToShowPromotionsVC(_: UITableViewCell? = nil) {
        if rideManager.isRiding {
            showAlert(message: "You may enter promo code after the trip.")
        }
        else {
            showPromoVC()
        }
    }
    
    private func attemptToShowFemaleDriverVC(_: UITableViewCell? = nil) {
        let gender = currentRider?.user.gender ?? "UNKNOWN"
        if let womanOnly = global.womanOnly(),
            let eligibleGenders = womanOnly.eligibleGenders {
            if eligibleGenders.contains(gender) {
                showFemaleDriverVC()
            }
            else if let options = global.genderSelection?.options, options.contains(gender) {
                showAlert(with: womanOnly.ineligibleGenderAlert) { [weak self] _ in
                    self?.showEditProfileVC()
                }
            }
            else {
                showAlert(with: womanOnly.unknownGenderAlert) { [weak self] _ in
                    self?.showGenderVC()
                }
            }
        }
        else {
            showFemaleDriverVC()
        }
    }
    
    private func showFingerprintedDrivers(model: RADriverTypeDataModel) {
        let vc = FingerprintedDriverModeViewController(model: model)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showAccessibilityDriver(_ cell: UITableViewCell, _ acDriver: ConfigAccessibleDriver) {
        
        guard let phoneNumber = acDriver.phoneNumber else { return }
        let alert = UIAlertController(
            title: "For Accessible Service rides",
            message: acDriver.title,
            preferredStyle: .actionSheet
        )
        
        if let popoverPresentationController = alert.popoverPresentationController {
            alert.message = alert.message ?? "" + "\n\(phoneNumber)"
            popoverPresentationController.sourceView = cell
            popoverPresentationController.sourceRect = cell.bounds
        }
        
        if let phoneUrl = URL(string: "tel:\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneUrl) {
            alert.addAction(UIAlertAction(
                title: "CALL",
                style: .default,
                handler: { _ in
                    UIApplication.shared.openURL(phoneUrl)
                }
            ))
        }
        alert.addAction(UIAlertAction(
            title: "CANCEL",
            style: .cancel,
            handler: nil
        ))
        navigationController.present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(with config: (ConfigAlert), handler: @escaping (UIAlertAction) -> Void) {
        if config.enabled {
            let alert = UIAlertController(
                title: nil,
                message: config.message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: config.actionTitle,
                style: .default,
                handler: handler
            ))
            alert.addAction(UIAlertAction(
                title: config.cancelTitle,
                style: .cancel,
                handler: nil
            ))
            navigationController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showCampaignProvider(_ provider: RACampaignProvider) {
        SVProgressHUD.show(withStatus: "PLEASE WAIT...")
        RACampaignAPI.getCampaignsForProvider(provider.modelID, withCompletion: { [weak self] (campaigns, error) in
            SVProgressHUD.dismiss()
            if let campaigns = campaigns {
                self?.campaignCoordinator?.setupWithList(
                    provider: provider,
                    providerCampaigns: campaigns
                )
            }
            else {
                self?.navigate(toError: error)
            }
        })
    }
    
    private func showDirectConnectInputVC() {
        let vc = DirectConnectViewController(delegate: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showDirectConnectDetailVC(model: RADriverDirectConnectDataModel) {
        let vc = UIStoryboard(name: "DirectConnect", bundle: nil).instantiateViewController(withIdentifier: DCDriverDetailViewController.className()) as! DCDriverDetailViewController //swiftlint:disable:this force_cast
        vc.driverDirectConnectDataModel = model
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showDriverSignup(_: UITableViewCell? = nil) {
        if DSFlowController.shouldShowInMenu(for: currentRider!.user) {
            self.driverSignUpCoordinator = DSFlowController(
                appContainer: appContainer,
                navigationController: navigationController
            )
            driverSignUpCoordinator?.startDriverSignup()
        }
        else {
            showAlert(message: "Current rider is already a driver")
        }
    }
    
    @objc
    private func showEditProfileVCFromMenu() {
        menu.hide()
        showEditProfileVC()
    }
    
    private func showEditProfileVC() {
        let vc = EditViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFemaleDriverVC() {
        let vc = WomanOnlyViewController()
        vc.delegate = femaleDriverViewDelegate
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showGenderVC() {
        guard let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: GenderViewController.className()) as? GenderViewController else {
            assertionFailure("Expecting GenderViewController")
            return
        }
        vc.viewModel = GenderViewModel(
            config: global,
            andDidSaveGenderHandler: { [weak self] user in
                self?.navigationController.popViewController(animated: false)
                if let eligibleGenders = self?.global.womanOnly()?.eligibleGenders,
                   let gender = user.gender,
                   eligibleGenders.contains(gender) {
                    self?.showFemaleDriverVC()
                }
            }
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    // used in MapCoordinator
    func showPaymentFlow() {
        if ApplePayHelper.canMakePayment() ||
            currentRider?.hasValidCard() == true {
            let vc = PaymentViewController()
            navigationController.pushViewController(vc, animated: true)
        }
        else {
            let vc = AddPaymentViewController()
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    // used in MapCoordinator
    func showPromoVC() {
        let vc = PromotionsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    // used in MapCoordinator
    func showRoundUpVC() {
        let vc = RoundUpViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showSettingsVC(_: UITableViewCell? = nil) {
        let vc = SettingsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showTripHistoryVC() {
        let vc = UIStoryboard(name: "TripHistory", bundle: nil).instantiateViewController(withIdentifier: TripHistoryViewController.className())
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showRatingViewWithRideId(rideId: String) {
    
        RARideAPI.getRide(rideId, withRiderLocation: nil) { (ride, _) in
            if let ride = ride {
                let unrated = UnratedRide(ride: ride, andPaymentMethod: (RASessionManager.shared().currentRider?.preferredPaymentMethod)!)
                let rateVC = RatingViewController()
                let vm = RatingViewModel(ride: unrated, configuration: ConfigurationManager.shared())
                vm?.isFromDeeplink = true
                rateVC.viewModel = vm
                rateVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController.present(rateVC, animated: true, completion: nil)
                }
            }
        }
    }
}

extension SideMenuCoordinator: VKSideMenuDataSource {
    
    func numberOfSections(in sideMenu: VKSideMenu) -> Int {
        return 1
    }
    
    func sideMenu(_ sideMenu: VKSideMenu, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func sideMenu(_ sideMenu: VKSideMenu, itemForRowAt indexPath: IndexPath) -> VKSideMenuItem {
        let menuItem = menuItems[indexPath.row]
        let item = VKSideMenuItem()
        item.title = menuItem.title
        if let iconName = menuItem.iconName {
            item.icon = UIImage(named: iconName)
        }
        else if let iconUrl = menuItem.iconUrl {
            SDWebImageManager.shared.loadImage(with: iconUrl, options: .highPriority, progress: nil) { (image, _, _, _, _, _) in
                item.icon = image
                sideMenu.tableView?.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
        }
        item.iconColor = menuItem.iconColor
        return item
    }
    
    func sideMenu(_ sideMenu: VKSideMenu, headerViewForSection section: Int) -> UIView {
        if headerView == nil {
            headerView = RASideMenuHeaderView(
                width: sideMenu.width,
                target: self,
                action: #selector(showEditProfileVCFromMenu)
            )
        }
        if let user = currentRider?.user {
            headerView?.updateName(user.firstname, imageURL: user.photoURL)
        }
        return headerView ?? UIView()
    }
    
}

extension SideMenuCoordinator: VKSideMenuDelegate {
    
    func sideMenuDidHide(_ sideMenu: VKSideMenu) {
        sideMenu.tableView?.isUserInteractionEnabled = true
        headerView = nil
    }
    
    func sideMenuDidShow(_ sideMenu: VKSideMenu) {
        sideMenu.tableView?.isUserInteractionEnabled = true
    }
    
    func sideMenu(_ sideMenu: VKSideMenu, didSelectRowAt indexPath: IndexPath) {
        sideMenu.tableView?.isUserInteractionEnabled = false //RA-3525
        let item = menuItems[indexPath.row]
        if let cell = sideMenu.tableView?.cellForRow(at: indexPath) {
            item.didTapBlock?(cell)
        }
    }
    
}

extension SideMenuCoordinator: SideMenuProtocol {
    
    func showSideMenu() {
        if menu.isVisible() {
            menu.hide()
        }
        else {
            updateMenu()
            menu.show()
        }
    }
    
    func hideSideMenu() {
        menu.hide()
    }
    
}

extension SideMenuCoordinator: DCDriverDetailViewControllerDelegate {
    
    func dcDriverDetailViewControllerCheckLocationPermissions(_ dcDriverDetailViewController: DCDriverDetailViewController?) -> Bool {
        return checkLocationPermissions()
    }
    
}

extension SideMenuCoordinator {
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))
        navigationController.present(alert, animated: true, completion: nil)
    }
    
    //duplicates MapCoordinator
    private func navigate(toError error: Any?) {
        guard let error = error as? RAAlertItem else {
            assertionFailure("Expecting RAAlertItem")
            return
        }
        RAAlertManager.showError(with: error, andOptions: RAAlertOption(shownOption: .AllowNetworkError))
    }
    
}

extension SideMenuCoordinator: DirectConnectViewControllerDelegate {
    func hdirectConnectViewController(_: DirectConnectViewController?, didTapSubmit model: RADriverDirectConnectDataModel) {
        showDirectConnectDetailVC(model: model)
    }
}
