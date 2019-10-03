import Foundation
import URITemplate

struct RequestTokenLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://requestToken={token}"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links {
            let template = URITemplate(template: link)
            if let parameters = template.extract(url.absoluteString),
                let token = parameters["token"] {
                return MapDeepLink.requestToken(token: token)
            }
        }
        return nil
    }
    
}
