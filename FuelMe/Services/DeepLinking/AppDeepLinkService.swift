import UIKit

/// Defines the deep links available for this application. Each deep
/// link can wrap the associated values it needs to display its
/// content. When adding a new deep link, you should also add a parser
/// for that deep link to the AppDeepLinkService.
enum MapDeepLink: DeepLink {
    case requestToken(token: String)
}

enum SideMenuDeepLink: DeepLink {
    case driverSignup
    case editProfile
    case rateRide(rideId: String)
    case tripHistory
}

/// Used by the `AppDelegate` to parse URLs, notifications and
/// shortcuts. The `DeepLinkService` will loop through each parser and
/// return the first deep link that matches.
struct AppDeepLinkService: DeepLinkService {
    
    let parsers: [DeepLinkParser]
    
    init() {
        self.parsers = [
            DriverSignupLinkParser(),
            RatingLinkParser(),
            RequestTokenLinkParser(),
            SettingsLinkParser(),
            TripHistoryLinkParser(),
        ]
    }
    
}
