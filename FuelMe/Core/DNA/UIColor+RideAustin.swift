import UIKit

extension UIColor {
    
    static var azureBlue: UIColor {
        return UIColor(2, 167, 249)
    }
    static var barButtonGray: UIColor {
        return UIColor(44, 50, 60)
    }
    
    static var barButtonDisabled: UIColor {
        return UIColor(233, 233, 233)
    }
    
    static var barButtonEnabled: UIColor {
        return UIColor(2, 167, 249)
    }
    
    static var bombayGray: UIColor {
        return UIColor(177, 180, 187)
    }
    
    static var grayBackground: UIColor {
        return UIColor(242, 242, 243)
    }
    
    static var textFieldBorder: UIColor {
        return UIColor(216, 216, 216)
    }
    
    static var placeholderColor: UIColor {
        return UIColor(199, 199, 205)
    }
    
    /// charcoalGrey
    static var grayText: UIColor {
        return UIColor(60, 67, 80)
    }
    
    /// coolGrey
    static var coolGrey: UIColor {
        return UIColor(145, 148, 153)
    }
    
    static var pickupGreen: UIColor {
        return UIColor(76, 175, 80)
    }
    
    static var pickupStrokeColor: UIColor {
        return pickupGreen
    }
    
    static var pickupPolygonFill: UIColor {
        return pickupGreen.withAlphaComponent(0.1)
    }
    
    static var destinationRed: UIColor {
        return UIColor(244, 67, 54)
    }
    
    static var destinationStrokeColor: UIColor {
        return destinationRed
    }
    
    static var destinationPolygonFill: UIColor {
        return destinationRed.withAlphaComponent(0.1)
    }
    
    static var mediumCandyAppleRed: UIColor {
        return UIColor(208, 2, 27)
    }
    
    static var femaleDriverPink: UIColor {
        return UIColor(249, 22, 135)
    }
    
}

extension UIColor {
    ///r/255, g/255, b/255
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
