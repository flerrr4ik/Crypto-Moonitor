//
//  InfoCell.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

class InfoCell: UITableViewCell {
    
    static let identifier = "InfoCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "doc.on.doc")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var fullValueToCopy: String?

    func configure(with row: InfoRow) {
        titleLabel.text = row.title
        valueLabel.text = row.value
        fullValueToCopy = row.fullValue
        copyButton.isHidden = (row.fullValue == nil)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.05)
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.15
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 5
        contentView.layer.borderWidth = 0.6
        contentView.layer.borderColor = UIColor.systemGray4.cgColor

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(copyButton)

        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            copyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            copyButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 20),
            copyButton.heightAnchor.constraint(equalToConstant: 20),

            valueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }

    @objc private func copyTapped() {
        guard let text = fullValueToCopy else { return }
        UIPasteboard.general.string = text

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
