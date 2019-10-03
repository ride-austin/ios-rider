import UIKit

protocol KeyboardControllerDelegate: class {
    func keyboardDidUpdate(rect: CGRect, animation: KeyboardAnimation?)
}

final class KeyboardController: NSObject {
    
    weak var delegate: KeyboardControllerDelegate?
    
    override init() {
        super.init()
        setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardNotifications() {
        let notifications = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardDidShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardDidHideNotification,
        ]
        
        for notification in notifications {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(normalizeKeyboardNotification),
                name: notification,
                object: nil
            )
        }
    }
    
    @objc
    private func normalizeKeyboardNotification(notification: NSNotification) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        if let keyboardNotification = KeyboardChange(notification: notification) {
            let height = window.frame.height
            var rect: CGRect = .zero
            
            switch keyboardNotification.type {
            case .willShow, .didShow:
                var keyboardHeight = window.frame.height - keyboardNotification.end.origin.y
                keyboardHeight = min(keyboardHeight, keyboardNotification.end.height)
                rect.origin.x = keyboardNotification.end.minX
                rect.origin.y = height - keyboardHeight
                rect.size.height = keyboardNotification.end.height
                rect.size.width = keyboardNotification.end.width
                
                if #available(iOS 11.0, *) {
                    rect.size.height -= window.safeAreaInsets.bottom
                }
                
            case .willHide, .didHide:
                rect.origin.y = window.frame.height
            }
            
            delegate?.keyboardDidUpdate(
                rect: rect,
                animation: keyboardNotification.animation
            )
        }
    }
    
}
