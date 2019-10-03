import UIKit

final class FingerprintedDriverModeViewController: BaseViewController {

    // MARK: Private
    
    @IBOutlet weak private var optionSwitch: UISwitch!
    @IBOutlet weak private var optionLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    private var model: RADriverTypeDataModel

    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc
    init(model: RADriverTypeDataModel) {
        self.model = model
        super.init(nibName: FingerprintedDriverModeViewController.identifier, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private func setup() {
        title = model.menuTitle.localizedCapitalized
        SDWebImageManager.shared.loadImage(with: model.iconUrl, options: .highPriority, progress: nil) { [weak self] (image, _, _, _, _, _) in
            self?.iconImage.image = image
        }
        descriptionLabel.text = model.driverTypeDescription
        optionLabel.text = model.title
        subtitleLabel.text = model.displayTitle
        
        optionSwitch.isOn = RARideRequestManager.shared().isFingerprintedDriverOnlyModeOn
    }
    
    // MARK: - Action
    @IBAction
    private func optionSwitchValueChanged(_ sender: UISwitch) {
        if RARideRequestManager.shared().currentRideRequest != nil {
            sender.isOn = sender.isOn == false
            let ok = UIAlertAction(
                title: "Ok".localizedCapitalized,
                style: .default
            )
            let alert = UIAlertController(
                title: "Request On going".localizedCapitalized,
                message: "Please cancel the request to change your mode".localizedCapitalized ,
                preferredStyle: .alert
            )
            alert.addAction(ok)
            present(alert, animated: true)
        }
        else {
            RARideRequestManager.shared().isFingerprintedDriverOnlyModeOn = sender.isOn
        }
    }
    
}
