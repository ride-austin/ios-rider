// swiftlint:disable force_cast
import UIKit

public protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    public static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController: Identifiable {}

extension UITableViewCell: Identifiable {}

extension UITableViewHeaderFooterView: Identifiable {}

extension UITableView {
    public func register(_ cellClass: UITableViewCell.Type) {
        register(cellClass.self, forCellReuseIdentifier: cellClass.identifier)
    }
    
    public func registerNib(_ cellClass: UITableViewCell.Type) {
        register(UINib(nibName: String(describing: cellClass), bundle: nil), forCellReuseIdentifier: cellClass.identifier)
    }
    
    public func registerNib(_ cellClass: UITableViewHeaderFooterView.Type) {
        register(UINib(nibName: String(describing: cellClass), bundle: nil), forHeaderFooterViewReuseIdentifier: cellClass.identifier)
    }
    
    public func dequeue<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath) as! T
    }
}

extension UICollectionViewCell: Identifiable {}

extension UICollectionView {
    public func register(_ cellClass: UICollectionViewCell.Type) {
        register(cellClass.self, forCellWithReuseIdentifier: cellClass.identifier)
    }
    
    public func registerNib(_ cellClass: UICollectionViewCell.Type) {
        register(UINib(nibName: String(describing: cellClass), bundle: nil), forCellWithReuseIdentifier: cellClass.identifier)
    }
    
    public func dequeue<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath) as! T
    }
}

extension UIStoryboard {
    
    static func make<T>(_ viewControllerClass: T.Type, from storyboardName: String) -> T where T: UIViewController {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: viewControllerClass.identifier) as! T
    }
    
    func make<T>(_ viewControllerClass: T.Type) -> T where T: UIViewController {
        return instantiateViewController(withIdentifier: viewControllerClass.identifier) as! T
    }
    
}
