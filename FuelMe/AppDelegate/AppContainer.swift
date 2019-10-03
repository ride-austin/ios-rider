import Foundation

/// Inherits NSObject to be used in DSFlowController
@objc final class AppContainer: NSObject {
    
    var sessionManager: RASessionManager = RASessionManager.shared()
    var deviceTokenString: String?
    lazy var deepLinkService: DeepLinkService = {
        return AppDeepLinkService()
    }()
}
