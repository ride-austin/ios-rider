import Foundation
import URITemplate

struct RatingLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://rate?ride={rideId}"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links {
            let template = URITemplate(template: link)
            if let parameters = template.extract(url.absoluteString),
                let rideId = parameters["rideId"] {
                return SideMenuDeepLink.rateRide(rideId: rideId)
            }
        }
        return nil
    }

}
