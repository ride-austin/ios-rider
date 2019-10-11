import UIKit
import URITemplate

struct CheckrLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://checkr?driverId={driverId}&email={email}"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links {
            let template = URITemplate(template: link)
            if let parameters = template.extract(url.absoluteString),
                let driverId = parameters["driverId"],
                let email = parameters["email"] {
                return SideMenuDeepLink.openCheckr(driverId: driverId, email: email)
            }
        }
        return nil
    }
}
