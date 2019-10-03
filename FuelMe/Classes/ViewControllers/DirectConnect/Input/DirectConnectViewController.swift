import UIKit

protocol DirectConnectViewControllerDelegate: AnyObject {
    func hdirectConnectViewController(_ : DirectConnectViewController?, didTapSubmit model: RADriverDirectConnectDataModel)
}

final class DirectConnectViewController: BaseViewController {
    // MARK: Private
    
    private var noHistoryLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.textColor = UIColor.charcoalGrey()
        view.text = "No History Available.".localizedCapitalized
        view.isHidden = true
        return view
    }()
    
    private var descriptionLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.textColor = UIColor.charcoalGrey()
        view.text = "Direct Connect enables you to pair with your driver by simply entering in their Driver ID."
        return view
    }()
    
    private var driverIdTextField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.placeholder = "Enter Driver ID".localizedCapitalized
        view.textColor = UIColor.charcoalGrey()
        view.borderStyle = .roundedRect
        view.keyboardType = .numberPad
        view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        return view
    }()
    
    private var submitButton: RAButton = {
        let view = RAButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Submit".localizedUppercase, for: .normal)
        view.isEnabled = false
        view.backgroundColor = UIColor.disabledButton()
        view.enabledColor = UIColor.azureBlue()
        view.disabledColor = UIColor.disabledButton()
        view.layer.cornerRadius = 23
        view.clipsToBounds = true
        view.addTarget(self, action: #selector(submitAction(_:)), for:
            .touchUpInside)
        return view
    }()
    
    private var historyTitle: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.textColor = UIColor.charcoalGrey()
        view.text = "Direct Connect History".localizedCapitalized
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.register(DCHistoryCell.self)
        return view
    }()
    
    private weak var delegate: DirectConnectViewControllerDelegate?
    private var items: [RADirectConnectHistory?]
    
    init(delegate: DirectConnectViewControllerDelegate) {
        self.delegate = delegate
        items = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.configureAllTapsWillDismissKeyboard()
        setup()
    }
    
    private func setupData() {
        self.showHUD()
        
        if let riderID = RASessionManager.shared().currentUser?.riderID()?.stringValue {
            RADriverAPI.getDriverConnectHistory(withRiderId: riderID) { [weak self] (history, error) in
                self?.hideHUD()
                if let error = error {
                    RAAlertManager.showError(with: error as RAAlertItem, andOptions: RAAlertOption(state: .StateAll, andShownOption: .AllowNetworkError))
                }
                else {
                    if let history = history {
                        self?.applyFilter(history)
                    }
                }
            }
        }
    }
    
    private func applyFilter(_ history: [RADirectConnectHistory?] ) {
        let groupedById = history.compactMap { $0 }.groupBy { $0.directConnectId }
        items = []
        
        for item in groupedById {
            let latestDriver = item.value.max { (lhs, rhs) -> Bool in
                switch (lhs.requestedAt, rhs.requestedAt) {
                case let (.some(lhs), .some(rhs)):
                    return lhs < rhs
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return true
                }
            }
            if let latest = latestDriver {
                items.append(latest)
            }
        }
        noHistoryLabel.isHidden = self.items.count > 0
        tableView.reloadData()
    }
    
    private func loadDirectConnectDetailFromID(_ driverID: String?) {
        self.showHUD()
        if let driverID = driverID {
            RADriverAPI.getDriverConnect(withId: driverID) { (directConnectModel, error) in
                self.hideHUD()
                if let error = error {
                    RAAlertManager.showError(with: error as RAAlertItem, andOptions: RAAlertOption(state: .StateAll, andShownOption: .AllowNetworkError))
                }
                else {
                    if let model = directConnectModel {
                        self.delegate?.hdirectConnectViewController(self, didTapSubmit: model)
                    }
                }
            }
        }
    }
    
    private func setup() {
        setupLayout()
        self.title = "Direct Connect"
        setupData()
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor.grayBackground()
        var constraints: [NSLayoutConstraint] = []
        view.addSubview(descriptionLabel)
        constraints.append(contentsOf: [
           descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
           descriptionLabel.widthAnchor.constraint(equalToConstant: 290),
           descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        view.addSubview(driverIdTextField)
        constraints.append(contentsOf: [
           driverIdTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 35),
           driverIdTextField.heightAnchor.constraint(equalToConstant: 40),
           driverIdTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
           driverIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
            ])
        
        view.addSubview(submitButton)
        constraints.append(contentsOf: [
            submitButton.topAnchor.constraint(equalTo: driverIdTextField.bottomAnchor, constant: 15),
            submitButton.heightAnchor.constraint(equalToConstant: 45),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
            ])
        
        view.addSubview(historyTitle)
        constraints.append(contentsOf: [
            historyTitle.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 32),
            historyTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            historyTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
            ])
        
        view.addSubview(tableView)
        constraints.append(contentsOf: [
            tableView.topAnchor.constraint(equalTo: historyTitle.bottomAnchor, constant: 13),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
            ])
        
        view.addSubview(noHistoryLabel)

        constraints.append(contentsOf: [
            noHistoryLabel.topAnchor.constraint(equalTo: historyTitle.bottomAnchor, constant: 33),
            noHistoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            noHistoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
            ])
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let count = textField.text?.count, let text = textField.text {
            if count > 0 {
                if text.isOnlyNumber() {
                    submitButton.isEnabled = true
                }
            }
            else {
                submitButton.isEnabled = false
            }
        }
    }
    
    @objc private func submitAction(_ sender: RAButton) {
        loadDirectConnectDetailFromID(driverIdTextField.text)
    }
    
}

extension DirectConnectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DCHistoryCell.self, for: indexPath)
        let model = items[indexPath.row]
        if let history = model {
            cell.setupWithModel(history)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        if let history = model {
            loadDirectConnectDetailFromID(history.directConnectId)
        }
    }
}

extension Sequence {
    
    func groupBy<G: Hashable>(closure: (Iterator.Element) -> G) -> [G: [Iterator.Element]] {
        var results = [G: [Iterator.Element]]()
        
        forEach {
            let key = closure($0)
            
            if var array = results[key] {
                array.append($0)
                results[key] = array
            }
            else {
                results[key] = [$0]
            }
        }
        
        return results
    }
}
