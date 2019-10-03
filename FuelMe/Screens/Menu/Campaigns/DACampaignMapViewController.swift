import GoogleMaps
import Pulley
import RxCocoa
import RxSwift
import UIKit

protocol DACampaignMapViewControllerDelegate: AnyObject {
    func daCampaignMapViewControllerDidTapBackButton(_: DACampaignMapViewController)
}

final class DACampaignMapViewController: UIViewController {
    
    // MARK: Private
    
    private var headerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont(name: FontTypeRegular, size: 13)
        view.textColor = UIColor.charcoalGrey()
        return view
    }()
    
    private var imageActivityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()
    
    private var headerLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var mapView: GMSMapView = {
        let view = GMSMapView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isIndoorEnabled = false
        view.settings.rotateGestures = false
        view.settings.myLocationButton = false
        view.isMyLocationEnabled = true
        view.padding = UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0)
        return view
    }()
    
    private var backButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "backArrow"), for: .normal)
        view.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return view
    }()
    
    private var currentLocationButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "current-location"), for: .normal)
        view.addTarget(self, action: #selector(handleCurrentLocationButton), for: .touchUpInside)
        return view
    }()
    
    private var zoomBoundsForAll: GMSCoordinateBounds?
    private var campaigns: [RACampaignDetail]!
    private var backButtonBottomConstraint: NSLayoutConstraint?
    private var currentLocationButtonBottomConstraint: NSLayoutConstraint?
    private final let bottomConstraintConstant: CGFloat = 10.0
    private let disposeBag = DisposeBag()
    private weak var delegate: DACampaignMapViewControllerDelegate?
    private weak var drawerViewControllerCount: BehaviorRelay<Int>?
    private weak var selectedCampaign: BehaviorRelay<RACampaignDetail?>?
    
    // MARK: Public
    
    convenience init(
        campaigns: [RACampaignDetail],
        delegate: DACampaignMapViewControllerDelegate,
        drawerViewControllerCount: BehaviorRelay<Int>,
        selectedCampaign: BehaviorRelay<RACampaignDetail?>
        ) {
        self.init()
        self.campaigns = campaigns
        self.delegate = delegate
        self.drawerViewControllerCount = drawerViewControllerCount
        self.selectedCampaign = selectedCampaign
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateZoom()
    }
    
    // MARK: Private
    
    @objc
    private func handleBackButton(sender: UIButton!) {
        delegate?.daCampaignMapViewControllerDidTapBackButton(self)
    }
    
    @objc
    private func handleCurrentLocationButton(sender: UIButton!) {
        guard let lat = mapView.myLocation?.coordinate.latitude,
            let lng = mapView.myLocation?.coordinate.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: mapView.camera.zoom)
        mapView.animate(to: camera)
    }
    
}

extension DACampaignMapViewController {
    
    private func setup() {
        setupLayout()
        setupMapObjects()
        setupZoom()
        setupHeader()
        title = campaigns.first?.headerTitle
        setupBackButtonStateObserver()
        setupZoomStateObserver()
    }
    
    private func setupLayout() {
        headerView.addSubview(imageView)
        headerView.addSubview(titleLabel)
        view.addSubview(headerView)
        view.addSubview(mapView)
        view.addSubview(backButton)
        view.addSubview(currentLocationButton)
        backButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: backButton.bottomAnchor, constant: bottomConstraintConstant)
        currentLocationButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: bottomConstraintConstant)
        let constraints = [
            headerView.topAnchor.constraint(equalTo: view.compatibleTopAnchor()),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 82),
            
            imageView.widthAnchor.constraint(equalToConstant: 161),
            imageView.heightAnchor.constraint(equalToConstant: 54),
            imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            mapView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            backButtonBottomConstraint!,
            
            view.trailingAnchor.constraint(equalTo: currentLocationButton.trailingAnchor, constant: 5),
            currentLocationButtonBottomConstraint!,
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupMapObjects() {
        var zoomBoundsForAll = GMSCoordinateBounds()
        for campaign in campaigns! {
            for area in campaign.areas {
                let polygon = GMSPolygon(path: area.path())
                polygon.strokeColor = area.color(withAlpha: 1.0)
                polygon.fillColor = area.color(withAlpha: 0.4)
                polygon.strokeWidth = 2
                polygon.map = mapView
                zoomBoundsForAll = zoomBoundsForAll.includingPath(area.path())
            }
        }
        self.zoomBoundsForAll = zoomBoundsForAll
    }
    
    private func setupZoom() {
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            bottomSafeArea = view.safeAreaInsets.bottom
        }
        else {
            bottomSafeArea = 0
        }
        if let bottomInset = pulleyViewController?.collapsedDrawerHeight(bottomSafeArea: bottomSafeArea) {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        }
        mapView.camera = GMSCameraPosition.camera(withLatitude: 30.249279, longitude: -97.739173, zoom: 10.2345)
    }
    
    private func setupHeader() {
        guard let detail = campaigns.first else { return }
        imageActivityIndicatorView.startAnimating()
        imageView.sd_setImage(with: detail.headerIcon) {[weak self] (_, _, _, _) in
            self?.imageActivityIndicatorView.stopAnimating()
        }
        
        titleLabel.text = "Check the map below to view the qualifying zone.".localizedCapitalized
    }
    
    private func setupBackButtonStateObserver() {
        drawerViewControllerCount?.asDriver().drive(onNext: { [weak self] count in
            self?.backButton.isHidden = count <= 1
        }).disposed(by: disposeBag)
    }
    
    private func setupZoomStateObserver() {
        selectedCampaign?.asDriver().drive(onNext: { [weak self] (campaign) in
            guard let strongSelf = self else { return }
            if let campaign = campaign {
                var zoomBoundsForOne = GMSCoordinateBounds()
                for area in campaign.areas {
                    zoomBoundsForOne = zoomBoundsForOne.includingPath(area.path())
                }
                strongSelf.mapView.animate(with: GMSCameraUpdate.fit(zoomBoundsForOne, withPadding: 15.0))
            }
            else if let zoom = strongSelf.zoomBoundsForAll, zoom.isValid {
                strongSelf.mapView.animate(with: GMSCameraUpdate.fit(zoom, withPadding: 15.0))
            }
        }).disposed(by: disposeBag)
    }
    
    private func updateZoom() {
        guard let zoom = zoomBoundsForAll else { return }
        mapView.animate(with: GMSCameraUpdate.fit(zoom, withPadding: 15.0))
    }
    
}

extension DACampaignMapViewController: PulleyPrimaryContentControllerDelegate {
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        guard drawer.currentDisplayMode == .drawer else {
            if let backButtonBottomConstraint = backButtonBottomConstraint {
                 backButtonBottomConstraint.constant = bottomConstraintConstant
            }
            
            if let currentLocationButtonBottomConstraint = currentLocationButtonBottomConstraint {
                currentLocationButtonBottomConstraint.constant = bottomConstraintConstant
            }

            return
        }

        if distance <= 268.0 + bottomSafeArea {
            if let backButtonBottomConstraint = backButtonBottomConstraint {
                backButtonBottomConstraint.constant = distance + bottomConstraintConstant
            }
            
            if let currentLocationButtonBottomConstraint = currentLocationButtonBottomConstraint {
                currentLocationButtonBottomConstraint.constant = distance + bottomConstraintConstant
            }
        }
        else {
            if let backButtonBottomConstraint = backButtonBottomConstraint {
                backButtonBottomConstraint.constant = 268.0 + bottomConstraintConstant
            }
            
            if let currentLocationButtonBottomConstraint = currentLocationButtonBottomConstraint {
                currentLocationButtonBottomConstraint.constant = 268.0 + bottomConstraintConstant
            }
        }
    }
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        let top: CGFloat = 5
        print("bottomSafeArea", bottomSafeArea)
        switch drawer.drawerPosition {
        case .collapsed:
            self.mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottomSafeArea, right: 0)
            
        case .partiallyRevealed:
            self.mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: 268, right: 0)
        default:
            break
        }
    }
    
}
