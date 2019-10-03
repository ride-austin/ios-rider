import UIKit

protocol CampaignListViewControllerDelegate: AnyObject {
    func campaignListViewController(_: CampaignListViewController, didTap campaign: RACampaignDetail, with campaigns: [RACampaignDetail])
}

final class CampaignListViewController: UIViewController {
    
    // MARK: Public
    
    weak var delegate: CampaignListViewControllerDelegate?
    
    // MARK: Private
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(UITableViewCell.self)
        return view
    }()
    
    private var items: [RACampaignDetail]
    
    // MARK: Public
    
    init(items: [RACampaignDetail]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: Private
    
    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
}

extension CampaignListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = item.headerTitle
        cell.textLabel?.font = UIFont(name: FontTypeRegular, size: 16)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension CampaignListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.campaignListViewController(self, didTap: item, with: items)
    }
    
}
