import UIKit
import URITemplate

struct CheckrLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://checkr?driverId={driverId}"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links {
            let template = URITemplate(template: link)
            if let parameters = template.extract(url.absoluteString),
                let driverId = parameters["driverId"] {
                return SideMenuDeepLink.openCheckr(driverId: driverId)
            }
        }
        return nil
    }
}
