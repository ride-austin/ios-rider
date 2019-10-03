import Foundation

struct DriverSignupLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://driverSignup"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links where link == url.absoluteString {
            return SideMenuDeepLink.driverSignup
        }
        return nil
    }
    
}
