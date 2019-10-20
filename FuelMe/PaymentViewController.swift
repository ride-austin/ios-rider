import Foundation
import UIKit

final class PaymentViewController: BaseViewController {
    
    enum Mode {
        case showCardsOnly
        case showAll
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableFooterView: UIView!
    
    private let mode: Mode
    private var paymentMethods: [PaymentItem] = []
    private var sections: [PaymentSectionItem] = []
    private var applePayPaymentItem: PaymentItem?
    private var popup: RAPaymentProviderInformationPopup?
    
    private static let kTitleApplePay = "Apple Pay"
    private static let kTitleSetupApplePay = "Set up Apple Pay"
    
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: "PaymentViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment"
        navigationController?.navigationBar.accessibilityIdentifier = title
        edgesForExtendedLayout = []
        configureTableView()
        showCardExpirationAlertIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSections()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        hideHUD()
    }

    // MARK: - Private
    
    private func addObservers() {
        if mode == .showAll && ApplePayHelper.canMakePayment() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateApplePayButton),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureSections),
            name: Notification.Name("kNotificationDidChangeConfiguration"),
            object: nil
        )
    }
    
    private func removeObservers() {
        if mode == .showAll && ApplePayHelper.canMakePayment() {
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("kNotificationDidChangeConfiguration"),
            object: nil
        )
    }
    
    @objc
    private func updateApplePayButton() {
        guard let applePayPaymentItem = applePayPaymentItem else { return }
        let text = ApplePayHelper.hasApplePaySetup() ? PaymentViewController.kTitleApplePay : PaymentViewController.kTitleSetupApplePay
        let didChangeText = applePayPaymentItem.text != text
        applePayPaymentItem.updateText(text)
        
        guard let rider = RASessionManager.shared().currentRider else { return }
        let isApplePaySelectedAndNoAvailableCards = rider.preferredPaymentMethod == .applePay && ApplePayHelper.hasApplePaySetup() == false
        
        if isApplePaySelectedAndNoAvailableCards {
            rider.preferredPaymentMethod = .primaryCreditCard
            tableView.reloadData() //reload primary card and apple pay payment item
        }
        else if didChangeText {
            tableView.reloadData() //reload primary card and apple pay payment item
        }
    }
    
    private func configureTableView() {
        tableView.backgroundColor = self.view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(PaymentMethodTableCell.self)
        tableView.registerNib(PaymentSectionFooterCell.self)
        tableView.registerNib(PaymentSectionHeaderCell.self)
        tableView.tableFooterView = tableFooterView
    }
    
    @objc
    private func configureSections() {
        showHUD()
        RASessionManager.shared().reloadCurrentRider { [weak self] (rider, error) in
            guard let self = self else { return }
            self.hideHUD()
            self.sections = []
            if let error = error as RAAlertItem? {
                RAAlertManager.showError(with: error, andOptions: RAAlertOption(state: .StateAll))
            }
            else if let rider = rider {
                if let unpaidBalance = rider.unpaidBalance,
                    let config = ConfigurationManager.shared().global.unpaidBalance,
                    config.enabled {
                    let pay = PaymentItem(
                        text: unpaidBalance.displayAmount(),
                        textColor: UIColor(250, 7, 7),
                        iconItem: UIImage(named: "icon-unpaid-balance"),
                        accessoryType: .disclosureIndicator
                    )
                    pay.didSelectItem = { [weak self] _ in
                        self?.showUnpaidBalance(unpaidBalance: unpaidBalance)
                    }
                    let sectionUnpaidBalance = PaymentSectionItem(
                        header: config.title,
                        footer: config.subtitle,
                        andRowItems: [pay]
                    )
                    self.sections.append(sectionUnpaidBalance)
                }
            }
            
            self.paymentMethods = self.configurePaymentMethods()
            let sectionPaymentMethods = PaymentSectionItem(
                header: "Payment methods",
                footer: "",
                andRowItems: self.paymentMethods
            )
            self.sections.append(sectionPaymentMethods)
            _ = self.configurePaymentMethods()
            self.tableView.reloadData()
        }
    }
    
    private func configurePaymentMethods() -> [PaymentItem] {
        var paymentItems: [PaymentItem] = []
        
        if mode == .showAll {
            if ApplePayHelper.canMakePayment() {
                let text = ApplePayHelper.hasApplePaySetup() ? PaymentViewController.kTitleApplePay : PaymentViewController.kTitleSetupApplePay
                let textColor = UIColor(60, 67, 80)
                if self.applePayPaymentItem == nil {
                    let item = PaymentItem(
                        text: text,
                        textColor: textColor,
                        andIconItem: UIImage(named: "apple_pay")
                    )
                    item.didSelectItem = { [weak self] paymentItem in
                        guard let self = self else { return }
                        guard self.canChangePaymentMethod() else {
                            self.showCantChangePaymentMethodAlert()
                            return
                        }
                        guard let rider = RASessionManager.shared().currentRider else { return }
                        
                        if rider.preferredPaymentMethod == .applePay {
                            rider.preferredPaymentMethod = .primaryCreditCard
                            self.tableView.reloadData()
                        }
                        else {
                            if ApplePayHelper.hasApplePaySetup() {
                                rider.preferredPaymentMethod = .applePay
                                if paymentItem?.text == PaymentViewController.kTitleSetupApplePay {
                                    self.updateApplePayButton()
                                }
                                else {
                                    self.tableView.reloadData()
                                }
                            }
                            else {
                                ApplePayHelper.openSettingsApplePay()
                            }
                        }
                    }
                    self.applePayPaymentItem = item
                }
                applePayPaymentItem!.updateText(text)
                paymentItems.append(applePayPaymentItem!)
            }
            
            if let payWithBevoBucks = ConfigurationManager.shared().global.ut?.payWithBevoBucks,
                payWithBevoBucks.enabled {
                let title = "Bevo Pay"
                let bevoPay = PaymentItem(
                    text: title,
                    textColor: UIColor(60, 67, 80),
                    andIconItem: UIImage(named: "bevoPay")
                )
                bevoPay.didSelectItem = { [weak self] paymentItem in
                    guard let self = self else { return }
                    guard self.canChangePaymentMethod() else {
                        self.showCantChangePaymentMethodAlert()
                        return
                    }
                    guard let rider = RASessionManager.shared().currentRider else { return }
                    rider.preferredPaymentMethod = (rider.preferredPaymentMethod == .bevoBucks) ? .primaryCreditCard : .bevoBucks
                    self.tableView.reloadData()
                }
                
                bevoPay.didTapInfoButton = { [weak self] in
                    guard let self = self else { return }
                    self.popup = RAPaymentProviderInformationPopup.paymentProvider(
                        withPhotoURL: payWithBevoBucks.iconLargeUrl,
                        name: title,
                        detail: payWithBevoBucks.shortDescription
                    )
                    self.popup?.show()
                }
                paymentItems.append(bevoPay)
            }
        }

        if let cards = RASessionManager.shared().currentRider?.cards {
            var creditCardPaymentItems: [PaymentItem] = []
            for card in cards {
                let item = PaymentItem(card: card)
                item.didSelectItem = { [weak self] paymentItem in
                    guard let self = self else { return }
                    guard self.canChangePaymentMethod() else {
                        self.showCantChangePaymentMethodAlert()
                        return
                    }
                    self.didSelectPaymentItemWithCard(paymentItem: item)
                }
                creditCardPaymentItems.append(item)
            }
            paymentItems.append(contentsOf: creditCardPaymentItems)
        }
        
        let addPayment = PaymentItem(
            text: "Add Payment",
            textColor: UIColor(2, 167, 249),
            andIconItem: UIImage(named: "add-icon")
        )
        addPayment.didSelectItem = { [weak self] _ in
            let vc = AddPaymentViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        paymentItems.append(addPayment)
        return paymentItems
    }
    
    private func didSelectPaymentItemWithCard(paymentItem: PaymentItem) {
        
        guard let row = paymentMethods.index(of: paymentItem) else { return }
        let section = sections.count - 1
        let indexPathForPaymentItem = IndexPath(row: row, section: section)
        let cell = tableView.cellForRow(at: indexPathForPaymentItem)
        
        guard let card = paymentItem.card else { return }
        if card.primary.boolValue == false {
            let preferredStyle: UIAlertController.Style = UI_USER_INTERFACE_IDIOM() == .pad ? .alert : .actionSheet
            let alert = UIAlertController(
                title: "Card Options",
                message: "Please, choose an option:",
                preferredStyle: preferredStyle
            )
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell!.bounds
            if card.cardExpired.boolValue == false {
                alert.addAction(UIAlertAction(
                    title: "Set as primary card",
                    style: .default,
                    handler: { [weak self] _ in
                        self?.processPrimaryCard(card: card)
                    }
                ))
            }
            
            alert.addAction(UIAlertAction(
                title: "Edit Card",
                style: .default,
                handler: { [weak self] _ in
                    self?.showEditPaymentForCard(card: card)
                }
            ))
            
            alert.addAction(UIAlertAction(
                title: "Delete Card",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.showDeleteConfirmationForCard(card: card)
                }
            ))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
        else {
            guard let rider = RASessionManager.shared().currentRider else { return }
            switch rider.preferredPaymentMethod {
            case .unspecified,
                 .primaryCreditCard:
                showEditPaymentForCard(card: card)
                
            case .applePay, .bevoBucks:
                rider.preferredPaymentMethod = .primaryCreditCard
                tableView.reloadData()
            }
        }
    }
    
    private func processPrimaryCard(card: RACardDataModel) {
        showHUD()
        let rider = RASessionManager.shared().currentRider
        rider?.setPrimaryCard(card, withCompletion: { [weak self] (error) in
            guard let self = self else { return }
            self.hideHUD()
            if let error = error as RAAlertItem? {
                RAAlertManager.showError(
                    with: error,
                    andOptions: RAAlertOption(state: .StateActive)
                )
            }
            else {
                self.configureSections()
            }
        })
    }
    
    private func showEditPaymentForCard(card: RACardDataModel) {
        let vc = EditPaymentViewController()
        vc.card = card
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showDeleteConfirmationForCard(card: RACardDataModel) {
        let alert = UIAlertController(
            title: "Delete Confirmation",
            message: "Are you sure you want to delete this card?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { [weak self] _ in
                self?.deleteCard(card: card)
            }
        ))
        present(alert, animated: true)
    }

    private func deleteCard(card: RACardDataModel) {
        showHUD()
        let rider = RASessionManager.shared().currentRider
        rider?.deleteCard(card, withCompletion: { [weak self] (error) in
            if let error = error as RAAlertItem? {
                self?.hideHUD()
                RAAlertManager.showError(
                    with: error,
                    andOptions: RAAlertOption(state: .StateActive)
                )
            }
            else {
                self?.configureSections()
            }
        })
    }
    
    // MARK: UnpaidBalance
    private func showUnpaidBalance(unpaidBalance: RAUnpaidBalance) {
        let config = ConfigurationManager.shared().global.unpaidBalance
        let vc = UIStoryboard.make(UnpaidBalanceViewController.self, from: "Payment")
        vc.viewModel = UnpaidBalanceViewModel(
            balance: unpaidBalance,
            paymentMethod: selectedPaymentItem(),
            config: config
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func selectedPaymentItem() -> PaymentItem? {
        let rider = RASessionManager.shared().currentRider!
        for item in paymentMethods {
            switch rider.preferredPaymentMethod {
            case .unspecified,
                .primaryCreditCard:
                if let card = item.card, card.primary.boolValue {
                    return item
                }
                
            case .bevoBucks where item.isBevoBucks():
                return item
                
            case .applePay where item.isApplePay():
                return item
                
            case .bevoBucks,
                 .applePay:
                break
            }
        }
        assertionFailure("It is unexpected that a payment item is not selected")
        return nil
    }
    
    // MARK: - Helpers
    
    private func showCardExpirationAlertIfNeeded() {
        guard let primaryCard = RASessionManager.shared().currentRider?.primaryCard() else { return }
        if primaryCard.cardExpired.boolValue {
            RAAlertManager.showAlert(
                withTitle: "",
                message: "Sorry your card has expired, please select or add a valid card",
                options: RAAlertOption(state: .StateActive)
            )
        }
    }

    private func showCantChangePaymentMethodAlert() {
        RAAlertManager.showAlert(
            withTitle: ConfigurationManager.appName(),
            message: "You can select another payment method after your trip.",
            options: RAAlertOption(state: .StateActive)
        )
    }

    private func canChangePaymentMethod() -> Bool {
        return RARideManager.shared().isRiding == false
    }
    
}

extension PaymentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionItem = sections[section]
        let view = tableView.dequeue(PaymentSectionHeaderCell.self)
        view.lbTitle.text = sectionItem.header
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionItem = sections[section]
        let view = tableView.dequeue(PaymentSectionFooterCell.self)
        view.lbTitle.text = sectionItem.footer
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PaymentMethodTableCell.self, for: indexPath)
        let rider = RASessionManager.shared().currentRider
        let section = sections[indexPath.section]
        if let paymentItem = section.rowItems[indexPath.row] as? PaymentItem {
            cell.paymentItem = paymentItem
            if let card = paymentItem.card {
                if card.primary.boolValue && (
                        rider?.preferredPaymentMethod == .some(.primaryCreditCard) ||
                        rider?.preferredPaymentMethod == .some(.unspecified)) {
                    cell.accessoryType = .checkmark
                    cell.accessibilityLabel = "Primary Card ending in \(card.cardNumber)"
                    cell.accessibilityHint = nil
                }
            }
            else {
                cell.accessibilityLabel = paymentItem.text
                cell.contentView.alpha = 1.0
            }
            
            if paymentItem.isApplePay(), rider?.preferredPaymentMethod == .some(.applePay) {
                cell.accessoryType = .checkmark
            }
            
            if paymentItem.isBevoBucks(), rider?.preferredPaymentMethod == .some(.bevoBucks) {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
    
}

extension PaymentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let paymentItem = sections[indexPath.section].rowItems[indexPath.row] as? PaymentItem else { return }
        paymentItem.didSelectItem?(paymentItem)
    }
    
}
