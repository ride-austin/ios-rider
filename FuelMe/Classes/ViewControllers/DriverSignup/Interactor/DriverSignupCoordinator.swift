import Foundation

@objc final class DSFlowController: NSObject & Coordinator {

    @objc var regConfig: ConfigRegistration?
    @objc var driver: DSDriver
    @objc var car: DSCar
    var rootViewController: UIViewController
    
    // MARK: ViewModels
    @objc var licenseViewModel: DSLicenseViewModel!
    @objc var insuranceViewModel: DSCarInsuranceViewModel!
    @objc var driverPhotoViewModel: DSDriverPhotoViewModel!
    @objc var chauffeurViewModel: DSChauffeurViewModel!
    @objc var inspectionStickerViewModel: DSInspectionStickerViewModel!
    @objc var carInfoViewModel: DSCarInfoViewModel!
    @objc var carLicensePlateViewModel: DSCarLicensePlateViewModel!
    @objc var carIsAddedViewModel: DSCarIsAddedViewModel!
    @objc var frontPhotoViewModel: DSCarPhotoViewModel!
    @objc var backPhotoViewModel: DSCarPhotoViewModel!
    @objc var insidePhotoViewModel: DSCarPhotoViewModel!
    @objc var trunkPhotoViewModel: DSCarPhotoViewModel!
    
    private weak var appContainer: AppContainer!
    private weak var navigationController: UINavigationController!
    private weak var presentedNavigationController: UINavigationController?
    private weak var startingViewController: UIViewController?
    private var coordinator: FingerprintsCoordinator?
    private var cache: SDImageCache
    
    private var storyboard: UIStoryboard {
        return UIStoryboard(name: "DriverSignup", bundle: nil)
    }
    
    init(
        appContainer: AppContainer,
        navigationController: UINavigationController
    ) {
        self.appContainer = appContainer
        self.navigationController = navigationController
        self.rootViewController = navigationController
        self.startingViewController = navigationController.topViewController
        if let cachedDriver = RACacheManager.cachedObject(forKey: DSDriver.className()) as? DSDriver {
            self.driver = cachedDriver
        }
        else {
            self.driver = DSDriver(email: RASessionManager.shared().currentUser?.email)
        }
        if let cachedCar = RACacheManager.cachedObject(forKey: DSCar.className()) as? DSCar {
            self.car = cachedCar
        }
        else {
            self.car = DSCar()
        }
        self.cache = SDImageCache(namespace: String(describing: DSFlowController.self))
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearDriverData),
            name: NSNotification.Name(rawValue: "kDidSignoutNotification"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public
    
    static func shouldShowInMenu(for currentUser: RAUserDataModel) -> Bool {
        if currentUser.isDriver() == false {
            return true
        }
        if RACacheManager.cachedObject(forKey: DSDriver.className()) != nil {
            return true
        }
        return false
    }
    
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        return false
    }
    
    func setup() {
        
    }
    
    func startDriverSignup() {
        showNextScreen(fromScreen: .unknown)
    }
    
    @objc
    func endDriverSignup() {
        guard let startingViewController = startingViewController else { return }
        navigationController.popToViewController(startingViewController, animated: true)
    }
    
    @objc
    func update(city: RACity, detail: RACityDetail) {
        if self.regConfig == nil {
            self.regConfig = ConfigRegistration.config(with: city, andDetail: detail)
            configureViewModels(with: regConfig!)
        }
        else {
            self.regConfig?.city = city
            self.regConfig?.cityDetail = detail
        }
        self.driver.cityId = city.cityID
    }
    
    @objc
    func submitRegistration(completion: @escaping (Error?) -> Void) {
        if let driverId = driver.modelID {
            submitDriverDependentTasks(driverId: driverId, completion: completion)
        }
        else {
            RADriverAPI.createDriver(
                driver,
                license: cachedDriverLicenseData(),
                insurance: cachedInsuranceData()
            ) { [weak self] (response, error) in
                if let error = error {
                    completion(error)
                }
                else if let response = response as? [String: Any],
                    let driverId = response["id"] as? NSNumber {
                    self?.driver.modelID = driverId
                    self?.saveContext()
                    self?.submitDriverDependentTasks(
                        driverId: driverId,
                        completion: completion
                    )
                }
            }
        }
    }
    
    // MARK: Private
    
    private func submitDriverDependentTasks(driverId: NSNumber, completion: @escaping (Error?) -> Void) {
        var uploadError: Error?
        
        let group = DispatchGroup()
        group.enter()
        if driverPhotoViewModel.isSubmitted == false {
            driverPhotoViewModel.submitDocument(withDriver: driverId) { (error) in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        if regConfig?.cityDetail.tnc.isEnabled == true {
            if chauffeurViewModel.isSubmitted == false &&
                (chauffeurViewModel.isMandatory || chauffeurViewModel.isProvided) {
                chauffeurViewModel.submitDocument(
                    withDriver: driverId,
                    city: driver.cityId
                ) { error in
                    uploadError = error
                    group.leave()
                }
            }
            else {
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        if self.car.modelID == nil {
            do {
                let json = try MTLJSONAdapter.jsonDictionary(fromModel: car)
                RADriverAPI.createCar(withParams: json, forDriverWithId: driverId.stringValue) { [weak self] (response, error) in
                    if let response = response as? [String: Any], let carId = response["id"] as? NSNumber {
                        self?.car.modelID = carId
                        self?.saveContext()
                    }
                    uploadError = error
                    group.leave()
                }
            }
            catch let error {
                group.leave()
                assertionFailure("parsing DSCar \(car) failed with \(error)")
            }
        }
        else {
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if let uploadError = uploadError {
                completion(uploadError)
            }
            else {
                guard let self = self else { return }
                self.submitCarDependentTasks(
                    carId: self.car.modelID!,
                    driverId: driverId,
                    completion: completion
                )
            }
        }
    }
    
    private func submitCarDependentTasks(
        carId: NSNumber,
        driverId: NSNumber,
        completion: @escaping (Error?) -> Void
    ) {
        let cityId = driver.cityId!
        var uploadError: Error?
        
        let group = DispatchGroup()
        group.enter()
        if frontPhotoViewModel.isSubmitted == false {
            frontPhotoViewModel.submitDocument(withDriver: driverId, car: carId) { error in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        if backPhotoViewModel.isSubmitted == false {
            backPhotoViewModel.submitDocument(withDriver: driverId, car: carId) { (error) in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        if insidePhotoViewModel.isSubmitted == false {
            insidePhotoViewModel.submitDocument(withDriver: driverId, car: carId) { (error) in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        if trunkPhotoViewModel.isSubmitted == false {
            trunkPhotoViewModel.submitDocument(withDriver: driverId, car: carId) { (error) in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.enter()
        inspectionStickerViewModel.isMandatory = isInspectionStickerMandatory()
        if inspectionStickerViewModel.isSubmitted == false &&
            (inspectionStickerViewModel.isMandatory || inspectionStickerViewModel.isProvided
            ) {
            inspectionStickerViewModel.submitDocument(withDriver: driverId, car: carId, city: cityId) { (error) in
                uploadError = error
                group.leave()
            }
        }
        else {
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if let uploadError = uploadError {
                completion(uploadError)
            }
            else {
                self?.clearDriverData()
                completion(nil)
            }
        }
    }
    
    private func configureViewModels(with config: ConfigRegistration) {
        //DSDriver , insurance, license
        licenseViewModel = DSLicenseViewModel(config: config, andCache: cache)
        licenseViewModel = DSLicenseViewModel(config: config, andCache: cache)
        insuranceViewModel = DSCarInsuranceViewModel(config: config, andCache: cache)
        
        //driver photo
        driverPhotoViewModel = DSDriverPhotoViewModel(config: config, andCache: cache)
        
        //chauffeur's permit
        chauffeurViewModel = DSChauffeurViewModel(config: config, andCache: cache)
        
        //Car year, make, model, color, license plate
        carInfoViewModel = DSCarInfoViewModel(config: config, andCache: cache)
        carLicensePlateViewModel = DSCarLicensePlateViewModel(config: config, andCache: cache)
        carIsAddedViewModel = DSCarIsAddedViewModel(config: config, andCache: cache)
        
        //DSCarPhotoViewModel car photo front
        frontPhotoViewModel = DSCarPhotoViewModel(type: FrontPhoto, config: config, andCache: cache)
        
        //DSCarPhotoViewModel car photo back
        backPhotoViewModel = DSCarPhotoViewModel(type: BackPhoto, config: config, andCache: cache)
        
        //DSCarPhotoViewModel car photo inside
        insidePhotoViewModel = DSCarPhotoViewModel(type: InsidePhoto, config: config, andCache: cache)
        
        //DSCarPhotoViewModel car photo trunk
        trunkPhotoViewModel = DSCarPhotoViewModel(type: TrunkPhoto, config: config, andCache: cache)
        
        //car registration sticker
        inspectionStickerViewModel = DSInspectionStickerViewModel(config: config, andCache: cache)
    }
    
    private func isInspectionStickerMandatory() -> Bool {
        let inspectionSticker: RAInspectionStickerDetail = regConfig!.cityDetail.inspectionSticker
        return inspectionSticker.isEnabled && Int(car.year)! <= inspectionSticker.minYearRequired.intValue
    }
    
    // MARK: Private Cache
    
    @objc
    private func clearDriverData() {
        cache.clearMemory()
        cache.clearDisk {
            print("cache is cleared")
        }
    }
    
    private func cachedInsuranceData() -> Data {
        return self.insuranceViewModel.cachedImage()!.compress(toMaxSize: 700000)
    }

    private func cachedDriverLicenseData() -> Data {
        return self.licenseViewModel.cachedImage()!.compress(toMaxSize: 700000)
    }

    private func saveContext() {
        RACacheManager.cacheObject(self.driver, forKey: DSDriver.className())
        RACacheManager.cacheObject(self.car, forKey: DSCar.className())
    }
    
    private func clearContext() {
        RACacheManager.removeObject(forKey: DSDriver.className())
        RACacheManager.removeObject(forKey: DSCar.className())
    }
    
}

// MARK: Flow

extension DSFlowController {
    
    @objc
    func showNextScreen(fromScreen: DSScreen) {
        switch viewControllerNextTo(fromScreen: fromScreen) {
        case let .some(vc):
            navigationController.pushViewController(vc, animated: true)
            
        case .none where fromScreen == .termsAndConditions:
            clearContext()
            coordinator = FingerprintsCoordinator(
                appContainer: appContainer,
                driverId: driver.modelID!.intValue,
                navigationController: navigationController
            )
            coordinator?.delegate = self
            coordinator?.setup()
            
        case .none:
            endDriverSignup()
        }
    }
    
    @objc
    func viewControllerNextTo(fromScreen: DSScreen) -> UIViewController? {
        switch fromScreen {
        case .carColor:
            let vc = storyboard.make(DSCarLicensePlateViewController.self)
            vc.coordinator = self
            return vc
            
        case .carInfo:
            let vc = storyboard.make(YearViewController.self)
            vc.coordinator = self
            return vc
            
        case .carInsurance:
            let vc = DriverFCRARightsViewController()
            vc.coordinator = self
            return vc
            
        case .carIsAdded:
            let vc = storyboard.make(InsuranceDocumentViewController.self)
            vc.coordinator = self
            return vc
            
        case .carLicensePlate:
            let vc = storyboard.make(DriverCarDetailsViewController.self)
            vc.coordinator = self
            return vc
            
        case .carMake:
            let vc = storyboard.make(ModelViewController.self)
            vc.coordinator = self
            return vc
            
        case .carModel:
            let vc = storyboard.make(ColorViewController.self)
            vc.coordinator = self
            return vc
            
        case .carPhotoBack:
            let vc = DriverCarPhotoViewController(type: InsidePhoto, andCoordinator: self)
            return vc
            
        case .carPhotoFront:
            let vc = DriverCarPhotoViewController(type: BackPhoto, andCoordinator: self)
            return vc
            
        case .carPhotoInside:
            let vc = DriverCarPhotoViewController(type: TrunkPhoto, andCoordinator: self)
            return vc
            
        case .carPhotoTrunk:
            let vc = storyboard.make(DriverCarInformationViewController.self)
            vc.coordinator = self
            return vc
            
        case .carSticker:
            let vc = storyboard.make(MakeViewController.self)
            vc.coordinator = self
            return vc
            
        case .carYear:
            if isInspectionStickerMandatory() {
                let vc = DriverInspectionStickerViewController()
                vc.coordinator = self
                return vc
            }
            else {
                let vc = storyboard.make(MakeViewController.self)
                vc.coordinator = self
                return vc
            }
            
        case .chauffeurPermitBack:
            let vc = DriverCarPhotoViewController(type: FrontPhoto, andCoordinator: self)
            return vc
            
        case .chauffeurPermitFront:
            if chauffeurViewModel.needsBackPhoto() {
                let vc = DriverTNCBackViewController()
                vc.coordinator = self
                return vc
            }
            else {
                let vc = DriverCarPhotoViewController(type: FrontPhoto, andCoordinator: self)
                return vc
            }
            
        case .citySelection:
            let vc = DriverPhotoViewController()
            vc.coordinator = self
            return vc
            
        case .driverLicense:
            if regConfig?.cityDetail.tnc.isEnabled == true {
                let vc = DriverTNCFrontViewController()
                vc.coordinator = self
                return vc
            }
            else {
                let vc = DriverCarPhotoViewController(type: FrontPhoto, andCoordinator: self)
                return vc
            }
            
        case .driverPhoto:
            let vc = storyboard.make(LicenseDocumentViewController.self)
            vc.coordinator = self
            return vc
           
        case .fcraAcknowledge:
            let vc = DriverDisclosureViewController()
            vc.coordinator = self
            return vc
            
        case .fcraDisclosure:
            let vc = DriverFCRAAckViewController()
            vc.coordinator = self
            return vc
            
        case .fcraRights:
            let vc = DriverFCRADisclosureViewController()
            vc.coordinator = self
            return vc
            
        case .termsAndConditions:
            return nil
            
        case .unknown:
            let vc = DriverSignUpViewController()
            vc.coordinator = self
            return vc
        }
    }
    
}

extension DSFlowController: FingerprintsCoordinatorDelegate {
    
    func didTapNotNow() {
        coordinator = nil
        endDriverSignup()
        clearContext()
        showAlert(NSString.accessibleAlertTitleRideAustin(), "Thank you for your application! We will reach out to you soon regarding next steps.")
    }
    
    func didFinishSuccessfully() {
        coordinator = nil
        endDriverSignup()
        clearContext()
        showAlert(NSString.accessibleAlertTitleRideAustin(), "Thank you for your application! We will reach out to you soon regarding next steps.")
    }
    
}
