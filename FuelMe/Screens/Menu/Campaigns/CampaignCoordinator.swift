import Foundation
import Pulley
import RxCocoa
import RxSwift

final class CampaignCoordinator: Coordinator {
    
    // MARK: Public
    
    let appContainer: AppContainer
    let rootViewController: UIViewController
    
    // MARK: Private
    
    private let mainNavigationController: UINavigationController
    private let drawerNavigationController: UINavigationController
    private var drawerViewControllerCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    private var selectedCampaign: BehaviorRelay<RACampaignDetail?> = BehaviorRelay<RACampaignDetail?>(value: nil)
    private let disposeBag = DisposeBag()
    
    // MARK: Public
    
    init(
        appContainer: AppContainer,
        navigationController: UINavigationController
         ) {
        self.appContainer = appContainer
        self.rootViewController = navigationController
        self.mainNavigationController = navigationController
        self.drawerNavigationController = UINavigationController()
        self.drawerNavigationController.isNavigationBarHidden = true
        drawerNavigationController.rx.willShow.subscribe(onNext: { [weak self] _ in
            self?.drawerViewControllerCount.accept(self?.drawerNavigationController.viewControllers.count ?? 0)
        }).disposed(by: disposeBag)
    }
    
    func setup() {
        assertionFailure("Unused")
    }
    
    func setupWithList(
        provider: RACampaignProvider? = nil,
        providerCampaigns: [RACampaignDetail]
        ) {
        let vc = CampaignListViewController(
            items: providerCampaigns
        )
        vc.delegate = self
        drawerNavigationController.setViewControllers([vc], animated: false)
        if providerCampaigns.count == 1, let selectedCampaign = providerCampaigns.first {
            showCampaignDetail(campaignDetail: selectedCampaign)
        }
        let mapVC = DACampaignMapViewController(
            campaigns: providerCampaigns,
            delegate: self,
            drawerViewControllerCount: drawerViewControllerCount,
            selectedCampaign: selectedCampaign
        )
        let pulleyVC = PulleyViewController(
            contentViewController: mapVC,
            drawerViewController: drawerNavigationController
        )
        pulleyVC.title = provider?.menuTitle ?? providerCampaigns.first?.headerTitle
        mainNavigationController.pushViewController(pulleyVC, animated: true)
    }
    
    func open(deepLink: DeepLink, type: DeepLinkType, animated: Bool) -> Bool {
        return false
    }
    
    private func showCampaignDetail(campaignDetail: RACampaignDetail) {
        let detailVC = DADetailViewController(detail: campaignDetail)
        selectedCampaign.accept(campaignDetail)
        drawerNavigationController.pushViewController(detailVC, animated: true)
    }
    
}

extension CampaignCoordinator: DACampaignMapViewControllerDelegate {
    
    func daCampaignMapViewControllerDidTapBackButton(_: DACampaignMapViewController) {
        selectedCampaign.accept(nil)
        drawerNavigationController.popToRootViewController(animated: true)
    }
    
}

extension CampaignCoordinator: CampaignListViewControllerDelegate {
    
    func campaignListViewController(_: CampaignListViewController, didTap campaign: RACampaignDetail, with campaigns: [RACampaignDetail]) {
        showCampaignDetail(campaignDetail: campaign)
    }
    
}
