import Foundation

struct TripHistoryLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://triphistory"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links where link == url.absoluteString {
            return SideMenuDeepLink.tripHistory
        }
        return nil
    }
    
}
