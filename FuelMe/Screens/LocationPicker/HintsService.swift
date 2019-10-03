import UIKit

@objc
final class HintsService: NSObject {
    
    private var config: ConfigGlobal
    
    @objc
    init(global: ConfigGlobal) {
        self.config = global
        super .init()
    }
    
    @objc
    /**
     This combines all areas for all hints
     */
    func pickupHintAreas() -> [GMSPath] {
        var paths: [GMSPath] = []
        if let pickUpHints = config.geocoding?.pickupHints {
            for hint in pickUpHints where hint.path() != nil {
                paths.append(hint.path())
            }
        }
        return paths
    }
    
    @objc
    func designatedPickupPointPins(isPickup: Bool) -> [GMSMarker] {
        var dots: [GMSMarker] = []
        if let pickUpHints = config.geocoding?.pickupHints {
            for item in pickUpHints {
                for point in item.designatedPickups {
                    let marker = GMSMarker(position: point.driverCoord.coordinate())
                    marker.isFlat = true
                    marker.groundAnchor = CGPoint(x: 0.5, y: 0.6)
                    marker.icon = isPickup ? Asset.dotGreen.image : Asset.dotRed.image
                    dots.append(marker)
                }
            }
        }
        return dots
    }
    
    @objc
    func getNearestPickupPoint(location: CLLocation) -> DesignatedPoint? {
        var distance: CLLocationDistance = Double.greatestFiniteMagnitude
        var nearestDesignatedPoint: DesignatedPoint?
        if let pickUpHints = config.geocoding?.pickupHints {
            for pickupHint in pickUpHints {
                for point in pickupHint.designatedPickups {
                    let currentDist = location.distance(from: point.driverCoord.location())
                    if currentDist <= distance {
                        distance = currentDist
                        nearestDesignatedPoint = DesignatedPoint(
                            address: pickupHint.name,
                            point: point
                        )
                    }
                }
            }
        }
        return nearestDesignatedPoint
    }
}

@objc
final class DesignatedPoint: NSObject {
    @objc
    var address: String
    @objc
    var point: RADesignatedPickup
    @objc
    init(address: String, point: RADesignatedPickup) {
        self.address = address
        self.point = point
        super.init()
    }
}
