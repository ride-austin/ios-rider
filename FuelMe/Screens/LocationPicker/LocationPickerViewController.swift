import UIKit

typealias LocationPickerCompletionBlock = (RAPickerAddressFieldType, RARideLocationDataModel?, Bool) -> Void
final class LocationPickerViewController: UIViewController {

    // MARK: Private
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var mapView: GMSMapView!
    @IBOutlet weak private var confirmButton: UIButton!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var pickupPointLabel: UILabel!
    @IBOutlet weak private var airportTitleLabel: UILabel!
    @IBOutlet weak private var bottomAirportHintDetailsView: ShadowBackgroundView!
    
    private var fieldType: RAPickerAddressFieldType
    private var hintsService: HintsService
    private var completion: LocationPickerCompletionBlock
    private var centerPin: UIImageView!
    private var zoomBoundsForAll: GMSCoordinateBounds?
    private var hintsPolygon: GMSPolygon!
    private var selectedPoint: DesignatedPoint?
    private var dotsArray: [GMSMarker] = []

    private var polygonStrokeColor: UIColor {
        switch self.fieldType {
        case .pickupFieldType:
            return .pickupStrokeColor
        case .destinationFieldType:
            return .destinationStrokeColor
        }
    }
    
    private var areaFillColor: UIColor {
        switch self.fieldType {
        case .pickupFieldType:
            return .pickupPolygonFill
        case .destinationFieldType:
            return .destinationPolygonFill
        }
    }
    
    private var confirmButtonTitle: String {
        switch self.fieldType {
        case .pickupFieldType:
            return "CONFIRM PICK-UP"
        case .destinationFieldType:
            return "CONFIRM DESTINATION"
        }
    }
    
    private var designatedPointIconImage: UIImage {
        switch self.fieldType {
        case .pickupFieldType:
            return Asset.iconPickup.image
        case .destinationFieldType:
            return Asset.iconDestination.image
        }
    }
    
    private var pinImage: UIImage {
        switch self.fieldType {
        case .pickupFieldType:
            return Asset.pinGreenPickup.image
        case .destinationFieldType:
            return Asset.pinRedLocation.image
        }
    }
    
    private var selectedMarkerImage: UIImage {
        switch self.fieldType {
        case .pickupFieldType:
            return Asset.dotGreenSelected.image
        case .destinationFieldType:
            return Asset.dotRedSelected.image
        }
    }
    
    private var markerImage: UIImage {
        switch self.fieldType {
        case .pickupFieldType:
            return Asset.dotGreen.image
        case .destinationFieldType:
            return Asset.dotRed.image
        }
    }
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupMap()
    }
    
    @objc
    init(fieldType: RAPickerAddressFieldType, completion: @escaping LocationPickerCompletionBlock ) {
        self.fieldType = fieldType
        self.hintsService = HintsService(global: ConfigurationManager.shared().global)
        self.completion = completion
        super.init(nibName: LocationPickerViewController.identifier, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    @IBAction
    private func backButtonPressed(_ sender: UIButton) {
        completion(self.fieldType, nil, false)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction
    private func confirmButtonPressed(_ sender: UIButton) {
        if let selectedPoint = self.selectedPoint {
            let location = RARideLocationDataModel(location: selectedPoint.point.driverCoord.location())
            location.address = selectedPoint.address
            location.visibleAddress = "\(selectedPoint.address) (\(selectedPoint.point.name))"
            completion(self.fieldType, location, true)
            navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(
                title: "",
                message: "Please select pickup within the green area",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    private func setupData() {
        confirmButton.setTitle(confirmButtonTitle, for: .normal)
        iconImageView.image = designatedPointIconImage
    }
    
    private func setupMap() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.isIndoorEnabled = false
        mapView.accessibilityElementsHidden = true
        mapView.animate(toZoom: kGMSMaxZoomLevel - 3)
        setupPin()
        setupPickupAreas()
        setupDots()
    }
    
    private func setupPickupAreas() {
        var zoomBoundsForAll = GMSCoordinateBounds()
        let paths = hintsService.pickupHintAreas()
        for path in paths {
            hintsPolygon = GMSPolygon(path: path)
            hintsPolygon.strokeColor = polygonStrokeColor
            hintsPolygon.fillColor = areaFillColor
            hintsPolygon.strokeWidth = 2
            hintsPolygon.map = mapView
            zoomBoundsForAll = zoomBoundsForAll.includingPath(path)
        }
        self.zoomBoundsForAll = zoomBoundsForAll
        updateZoom()
    }
    
    private func setupPin() {
        centerPin = UIImageView(image: pinImage)
        centerPin.translatesAutoresizingMaskIntoConstraints = false
        centerPin.contentMode = .scaleAspectFit
        centerPin.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        let margins = view.layoutMarginsGuide
        mapView.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            centerPin.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            centerPin.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupDots() {
        dotsArray = hintsService.designatedPickupPointPins(isPickup: fieldType == .pickupFieldType)
        for marker in dotsArray {
            marker.map = mapView

            if let selected = selectedPoint {
                if selected.point.driverCoord.coordinate().isEqual(location: marker.position) {
                    marker.icon = selectedMarkerImage
                }
                else {
                    marker.icon = markerImage
                }
            }
        }
    }
    
    private func updateDots() {
        for marker in dotsArray {
            if let selected = selectedPoint {
                if selected.point.driverCoord.coordinate().isEqual(location: marker.position) {
                    marker.icon = selectedMarkerImage
                }
                else {
                    marker.icon = markerImage
                }
            }
            marker.map = mapView
        }
    }
    
    private func updateZoom() {
        guard let zoom = zoomBoundsForAll else { return }
        mapView.animate(with: GMSCameraUpdate.fit(zoom, withPadding: 15.0))
    }
    
    private func updatePolygonWithPosition(position: GMSCameraPosition, shouldMovePin: Bool) {
        if let path = hintsPolygon.path {
            if GMSGeometryContainsLocation(position.target, path, true) == false {
                showPickupHintsPolygon(shouldShow: false)
            }
            else {
                showPickupHintsPolygon(shouldShow: true)
                if shouldMovePin {
                    moveToNearestPointWithLocation(location: position.target)
                }
            }
        }
    }
    
    private func moveToNearestPointWithLocation(location: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        if let nearestPoint = hintsService.getNearestPickupPoint(location: location) {
            selectedPoint = nearestPoint
            pickupPointLabel.text = nearestPoint.point.name
            mapView.animate(to: GMSCameraPosition(
                target: nearestPoint.point.driverCoord.coordinate(),
                zoom: mapView.camera.zoom,
                bearing: mapView.camera.bearing,
                viewingAngle: mapView.camera.viewingAngle
            ))
            updateDots()
        }
    }
    
    private func showPickupHintsPolygon(shouldShow: Bool) {
        if shouldShow {
            hintsPolygon.map = mapView
            bottomAirportHintDetailsView.isHidden = false
        }
        else {
            selectedPoint = nil
            hintsPolygon.map = nil
            bottomAirportHintDetailsView.isHidden = true
            mapView.clear()
        }
    }
}

extension LocationPickerViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        view.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updatePolygonWithPosition(position: position, shouldMovePin: true)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        updatePolygonWithPosition(position: position, shouldMovePin: false)
    }
}

extension CLLocationCoordinate2D {
    func isEqual(location: CLLocationCoordinate2D) -> Bool {
        return self.latitude == location.latitude && self.longitude == location.longitude
    }
}
