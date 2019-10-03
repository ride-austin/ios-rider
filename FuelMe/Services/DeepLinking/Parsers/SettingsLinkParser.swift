import Foundation

struct SettingsLinkParser: DeepLinkParser {
    
    private let links: [String] = [
        "rideaustin://editProfile"
    ]
    
    func parse(url: URL) -> DeepLink? {
        for link in links where link == url.absoluteString {
            return SideMenuDeepLink.editProfile
        }
        return nil
    }
    
}
