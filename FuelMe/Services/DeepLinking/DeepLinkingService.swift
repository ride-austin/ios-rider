import UIKit

protocol DeepLink {}

protocol DeepLinkService: DeepLinkParser {
    var parsers: [DeepLinkParser] { get }
}

extension DeepLinkService {
    
    func parse(url: URL) -> DeepLink? {
        for parser in parsers {
            if let deepLink = parser.parse(url: url) {
                return deepLink
            }
        }
        return nil
    }
    
}
