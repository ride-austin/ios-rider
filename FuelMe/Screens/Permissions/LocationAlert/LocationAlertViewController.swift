import UIKit

protocol LocationAlertViewControllerDelegate: AnyObject {
    func locationAlertViewControllerDidConfirm(_: LocationAlertViewController)
    func locationAlertViewControllerDidCancel(_: LocationAlertViewController)
}

final class LocationAlertViewController: UIViewController {
    
    @IBOutlet weak private var alertText: UILabel!
    @IBOutlet weak private var alertTitle: UILabel!
    @IBOutlet weak private var allowButton: UIButton!
    @IBOutlet weak private var notNowButton: UIButton!
    
    private weak var delegate: LocationAlertViewControllerDelegate?
    
    init(delegate: LocationAlertViewControllerDelegate) {
        super.init(nibName: "LocationAlertViewController", bundle: Bundle.main)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        alertTitle.text = "Location Services OFF"
        alertText.text = "Please allow location access to improve your pickup experience"
        allowButton.setTitle("Allow".uppercased(), for: .normal)
        notNowButton.setTitle("Not Now".uppercased(), for: .normal)
    }
    
    @IBAction func allowButtonPressed(_ sender: UIButton) {
        delegate?.locationAlertViewControllerDidConfirm(self)
    }
    
    @IBAction func notNowButtonPressed(_ sender: UIButton) {
        delegate?.locationAlertViewControllerDidCancel(self)
    }
}
