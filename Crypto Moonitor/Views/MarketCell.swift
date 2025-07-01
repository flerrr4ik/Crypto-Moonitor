//
//  MarketCell.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

final class MarketCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pairAndPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with ticker: Ticker, logoURL: String?) {
        nameLabel.text = ticker.market.name
        pairAndPriceLabel.text = "\(ticker.base)/\(ticker.target)\n$\(ticker.last)"
        loadLogoImage(from: logoURL)
    }
    
    // MARK: - Private Methods
    
    private func setupCellAppearance() {
        contentView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }
    
    private func setupViews() {
        // Configure logo image view
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 8
        logoImageView.clipsToBounds = true
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel.numberOfLines = 1
        
        // Configure pair and price label
        pairAndPriceLabel.font = UIFont.systemFont(ofSize: 11)
        pairAndPriceLabel.textColor = .secondaryLabel
        pairAndPriceLabel.numberOfLines = 2
        pairAndPriceLabel.adjustsFontSizeToFitWidth = true
        pairAndPriceLabel.minimumScaleFactor = 0.7
        
        // Create labels stack
        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, pairAndPriceLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.alignment = .leading
        labelsStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        labelsStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Create main horizontal stack
        let horizontalStack = UIStackView(arrangedSubviews: [logoImageView, labelsStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        
        // Add to content view and activate constraints
        contentView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),
            
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func loadLogoImage(from urlString: String?) {
        guard let logoURL = urlString, let url = URL(string: logoURL) else {
            logoImageView.image = UIImage(systemName: "questionmark")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.logoImageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
