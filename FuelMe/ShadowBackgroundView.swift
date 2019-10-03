import UIKit

final class ShadowBackgroundView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setShadowWithCornerRadius(corners: 4.0)
    }
    
    func setShadowWithCornerRadius(corners: CGFloat) {
        self.layer.cornerRadius = corners
        let shadowPath2 = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(0.0))
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = shadowPath2.cgPath
    }
}
