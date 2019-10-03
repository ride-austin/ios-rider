import UIKit
import SDWebImage

private let avatarDimension: CGFloat = 30

final class DCHistoryCell: UITableViewCell {

    private var avatarImage: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.image = Asset.personPlaceholder.image
        view.layer.cornerRadius = avatarDimension/2
        view.layer.masksToBounds = true
        return view
    }()
    
    private var nameLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont(name: FontTypeRegular, size: 13)
        view.textColor = UIColor.darkTitle()
        return view
    }()
    
    private var lastTripLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont(name: FontTypeRegular, size: 12)
        view.textColor = UIColor.darkTitle()
        view.textAlignment = .left
        view.text = "Last Trip".localizedCapitalized
        return view
    }()
    
    private var timeStampLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont(name: FontTypeLight, size: 12)
        view.textColor = UIColor.darkTitle()
        return view
    }()
    
    func setupWithModel(_ model: RADirectConnectHistory) {
        setupLayout()
        if let photoUrl = model.photoURL {
            avatarImage.sd_setImage(with: photoUrl, placeholderImage: Asset.personPlaceholder.image, options: .refreshCached, context: nil, progress: nil) { (image, _, _, _) in
                    self.avatarImage.image = image
            }
        }
       
        nameLabel.text = model.driverFirstName
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        if let requestedAt = model.requestedAt {
            timeStampLabel.text = dateFormatter.string(from: requestedAt)
        }
        else {
            timeStampLabel.text = "Unknown date"
        }
    }
    
    func setupLayout() {
        var constraints: [NSLayoutConstraint] = []
        let leadingMargin: CGFloat = 9
        let verticalMargin: CGFloat = 12
        contentView.addSubview(avatarImage)
        constraints.append(contentsOf: [
            avatarImage.widthAnchor.constraint(equalToConstant: avatarDimension),
            avatarImage.heightAnchor.constraint(equalToConstant: avatarDimension),
            avatarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            avatarImage.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: verticalMargin),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: avatarImage.bottomAnchor, constant: verticalMargin)
        ])
        
        contentView.addSubview(nameLabel)
        constraints.append(contentsOf: [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalMargin),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: leadingMargin),
            contentView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 12)
        ])
        
        contentView.addSubview(lastTripLabel)
        constraints.append(contentsOf: [
            lastTripLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            lastTripLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: leadingMargin),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: lastTripLabel.bottomAnchor, constant: verticalMargin)
        ])
        
        contentView.addSubview(timeStampLabel)
        constraints.append(contentsOf: [
            timeStampLabel.leadingAnchor.constraint(equalTo: lastTripLabel.trailingAnchor, constant: 5),
            contentView.trailingAnchor.constraint(equalTo: timeStampLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: timeStampLabel.bottomAnchor, constant: verticalMargin)
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 223/255.0, green: 223.0/255.0, blue: 223.0/255.0, alpha: 1.0).cgColor
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
