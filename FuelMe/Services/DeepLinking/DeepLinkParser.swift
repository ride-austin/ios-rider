import UIKit

protocol DeepLinkParser {
    func parse(url: URL) -> DeepLink?
}
