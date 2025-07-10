//
//  InfoCell.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

final class InfoCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let identifier = "InfoCell"
    
    // MARK: - UI Components
    
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
    
    // MARK: - Properties
    
    private var fullValueToCopy: String?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellAppearance()
        setupSubviews()
        setupConstraints()
        setupButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with row: InfoRow) {
        titleLabel.text = row.title
        valueLabel.text = row.value
        fullValueToCopy = row.fullValue
        copyButton.isHidden = (row.fullValue == nil)
    }
    
    // MARK: - Private Methods
    
    private func setupCellAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.15
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 5
        contentView.layer.borderWidth = 0.6
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(copyButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            copyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            copyButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 20),
            copyButton.heightAnchor.constraint(equalToConstant: 20),

            valueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    private func setupButtonAction() {
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
    }
    
    private func showCopiedMessage() {
        let messageLabel = UILabel()
        messageLabel.text = "Copied"
        messageLabel.textColor = .white
        messageLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        messageLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.alpha = 0
        messageLabel.layer.cornerRadius = 8
        messageLabel.clipsToBounds = true
        
        contentView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            messageLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            messageLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                messageLabel.alpha = 0
            }, completion: { _ in
                messageLabel.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Actions
    
    @objc private func copyTapped() {
        guard let text = fullValueToCopy else { return }
        UIPasteboard.general.string = text

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        showCopiedMessage()
    }
}
