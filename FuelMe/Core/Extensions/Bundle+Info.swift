// swiftlint:disable force_cast
import Foundation

extension Bundle {
    static func appName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    static func version() -> String {
        let info = Bundle.main.infoDictionary!
        
        return info["CFBundleShortVersionString"] as! String
    }
    
    static func completeVersion() -> String {
        let info = Bundle.main.infoDictionary!
        
        let version = info["CFBundleShortVersionString"] as! String
        let build = info[kCFBundleVersionKey as String] as! String
        
        return "\(version) (\(build))"
    }
}
