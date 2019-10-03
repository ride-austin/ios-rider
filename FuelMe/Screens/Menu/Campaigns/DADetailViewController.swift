import Pulley
import UIKit

final class DADetailViewController: UIViewController {
    
    // MARK: - Internal properties
    private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        return view
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.isScrollEnabled = false
        view.layer.borderColor = UIColor(white: 223/255.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 1
        view.isEditable = false
        view.isSelectable = true
        view.dataDetectorTypes = .link
        view.textContainerInset = UIEdgeInsets(top: 23, left: 19, bottom: 23, right: 19)
        view.textColor = UIColor.charcoalGrey()
        view.delegate = self
        return view
    }()
    
    private lazy var footerTextView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: FontTypeLight, size: 13)
        view.isScrollEnabled = false
        view.isEditable = false
        view.isSelectable = true
        view.dataDetectorTypes = .link
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 23, left: 19, bottom: 23, right: 19)
        view.textColor = UIColor.charcoalGrey()
        return view
    }()
    private var campaignDetail: RACampaignDetail!
    // MARK: - External properties / Dependency injection
    
    // MARK: - Setup
    @objc
    public convenience init(detail: RACampaignDetail) {
        self.init()
        self.campaignDetail = detail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

// MARK: - Private

extension DADetailViewController {
    
    private func setup() {
        view.backgroundColor = UIColor.grayBackground()
        self.pulleyViewController?.delegate = self
        setupLayout()
        setupData()
    }
    
    private func setupLayout() {
        // Perform setup
        // Add child views as subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textView)
        contentView.addSubview(footerTextView)
        
        // Setup constraints/frames
        let constraints = [
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            footerTextView.topAnchor.constraint(equalTo: textView.bottomAnchor),
            footerTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: footerTextView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: footerTextView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupData() {
        setup(with: self.campaignDetail)
    }
    
    private func setup(with detail: RACampaignDetail) {
        textView.attributedText = NSAttributedString.init(fromHTML: detail.body)
        footerTextView.attributedText = NSAttributedString.init(fromHTML: detail.footer)
    }
    
}

extension DADetailViewController: PulleyDrawerViewControllerDelegate {
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        switch drawer.drawerPosition {
        case .open:
            scrollView.isScrollEnabled = true
        default:
            scrollView.isScrollEnabled = false
        }
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [
            .collapsed,
            .partiallyRevealed,
            .open
        ]
    }
    
}

extension DADetailViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // HACK: RA-117 When highlighting the textView, buttons in the
        // DrawerContentViewController are not tappable
        view.endEditing(true)
    }
    
}
