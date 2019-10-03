import UIKit

struct KeyboardAnimation {
    let duration: TimeInterval
    let options: UIView.AnimationOptions
    let delay: TimeInterval = 0
    
    init?(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
            else { return nil }
        
        self.duration = duration.doubleValue == 0 ? 0.1 : duration.doubleValue
        options = UIView.AnimationOptions(rawValue: curve.uintValue == 0 ? 7 : curve.uintValue)
    }
}
