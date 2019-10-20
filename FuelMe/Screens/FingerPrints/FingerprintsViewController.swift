import UIKit

protocol FingerprintsViewControllerDelegate: AnyObject {
    func didTapPayment(_: FingerprintsViewController)
    func didTapSubmit(_: FingerprintsViewController)
    func didTapNotNow(_: FingerprintsViewController)
    func didTapContactSupport(_: FingerprintsViewController)
}

final class FingerprintsViewController: UIViewController {
   
    @IBOutlet private weak var noPaymentLabel: UILabel!
    @IBOutlet private weak var helpBarView: RAHelpBarView!
    @IBOutlet private weak var paymentTitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var backgroundCheckTextArea: UITextView!
    @IBOutlet private weak var paymentContainer: UIView!
    @IBOutlet private weak var saveButton: RAButton!
    @IBOutlet private weak var cardNumber: UILabel!
    @IBOutlet private weak var paymentIcon: UIImageView!
    private weak var delegate: FingerprintsViewControllerDelegate?

    init(delegate: FingerprintsViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: FingerprintsViewController.identifier, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotNowButton()
        setupTextView()
        setupHelpHeader()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePaymentItem()
    }
}

extension FingerprintsViewController {
    
    private func setupHelpHeader() {
        helpBarView.delegate = self
    }
    
    private func setupNotNowButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "NOT NOW", style: .plain, target: self, action: #selector(notNowTapped))
    }
    
    private func setupFonts() {
        titleLabel.font = UIFont(name: FontTypeLight, size: 19)
        titleLabel.textColor = .grayText
        titleLabel.text = "RideAustin uses a third party background check that costs 20$."
        subTitleLabel.font = UIFont(name: FontTypeRegular, size: 12)
        subTitleLabel.text = "THIS WILL BE REIMBURSED AFTER YOUR 100TH SUCCESSFUL TRIP"
        backgroundCheckTextArea.textColor = .grayText
    }
    
    private func setupTextView() {
        let backgroundString = "RideAustin also recommends you to get an optional fingerprint-based background check to qualify for additional RideAustin services."
        backgroundCheckTextArea.text = backgroundString
        backgroundCheckTextArea.isUserInteractionEnabled = true
        backgroundCheckTextArea.isEditable = false
        backgroundCheckTextArea.textColor = .grayText
    }
    
    private func updatePaymentItem() {
        let paymentItem: PaymentItem
        if let primaryCard = RASessionManager.shared().currentRider?.primaryCard() {
            paymentItem = PaymentItem(card: primaryCard)
            paymentIcon.image = paymentItem.iconItem
            cardNumber.text = paymentItem.text
            saveButton.isEnabled = true
            noPaymentLabel.text = nil
        }
        else {
            paymentIcon.image = nil
            cardNumber.text = nil
            noPaymentLabel.text = "Add Payment Method"
            saveButton.isEnabled = false
        }
        paymentContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentTapped)))
        paymentTitleLabel.text = "Please select the payment method"
    }
}

extension FingerprintsViewController {
    
    @objc
    private func notNowTapped() {
        delegate?.didTapNotNow(self)
    }
    
    @objc
    private func paymentTapped() {
        delegate?.didTapPayment(self)
    }
    
    @IBAction
    func submitButtonTapped(_ sender: Any) {
        delegate?.didTapSubmit(self)
    }
}

extension FingerprintsViewController: RAHelpBarViewDelegate {
    func didTapHelpBar() {
        delegate?.didTapContactSupport(self)
    }
}
