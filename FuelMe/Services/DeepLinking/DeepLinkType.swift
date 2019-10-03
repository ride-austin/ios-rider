import Foundation

/// Used to determine where a deep link was opened from. This can be
/// used to customize the animation when opening a deep link.
enum DeepLinkType {
    case url
    case applicationShortcut
    case pushNotification
    case notificationCenter
}
