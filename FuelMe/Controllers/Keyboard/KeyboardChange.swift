import UIKit

enum KeyboardChangeType {
    case willShow, willHide, didShow, didHide
    
    static func fromNotificationName(_ notificationName: NSNotification.Name) -> KeyboardChangeType? {
        switch notificationName {
        case UIResponder.keyboardDidHideNotification:
            return .didHide
        case UIResponder.keyboardWillHideNotification:
            return .willHide
        case UIResponder.keyboardDidShowNotification:
            return .didShow
        case UIResponder.keyboardWillShowNotification:
            return .willShow
        default:
            return nil
        }
    }
}

struct KeyboardChange {
    let type: KeyboardChangeType
    let begin: CGRect
    let end: CGRect
    let animation: KeyboardAnimation?
    
    init?(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let end = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let begin = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
            let type = KeyboardChangeType.fromNotificationName(notification.name) else { return nil }
        
        self.type = type
        self.end = end.cgRectValue
        self.begin = begin.cgRectValue
        animation = KeyboardAnimation(notification: notification)
    }
}
