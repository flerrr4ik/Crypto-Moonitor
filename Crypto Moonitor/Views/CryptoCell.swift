//
//  CryptoCell.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit
import SDWebImage

final class CryptoCell: UITableViewCell {
    
    // MARK: - UI Properties
    
    private let rankLabel = UILabel()
    private let iconImageView = UIImageView()
    private let symbolLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let priceLabel = UILabel()
    private let chartView = MiniChartView()
    private let priceChangeLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configureBasicInfo(with crypto: Crypto) {
        // Rank & Symbol
        rankLabel.text = "\(crypto.market_cap_rank)"
        rankLabel.textColor = UIColor.systemIndigo.withAlphaComponent(0.7)
        symbolLabel.text = crypto.symbol.uppercased()
        
        // Price Change
        if let change = crypto.price_change_percentage_24h {
            priceChangeLabel.text = String(format: "%.2f%%", change)
            let color: UIColor = change >= -0.01 ? .systemGreen : .systemRed
            priceChangeLabel.textColor = color
            chartView.setColor(color)
        } else {
            priceChangeLabel.text = "24h: N/A"
            priceChangeLabel.textColor = .gray
            chartView.setColor(.gray)
        }
        
        // Market Cap
        if let marketCap = crypto.market_cap {
            marketCapLabel.text = String(format: "$%.2fB", Double(marketCap) / 1_000_000_000)
        } else {
            marketCapLabel.text = "Market Cap: N/A"
        }
        
        // Price
        priceLabel.text = crypto.current_price < 1
            ? String(format: "$%.6f", crypto.current_price)
            : String(format: "$%.2f", crypto.current_price)
        
        // Icon
        if let url = URL(string: crypto.image) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
        }
    }
    
    func loadChart(with prices: [CGFloat]) {
        prices.isEmpty ? chartView.setEmpty() : chartView.setData(prices)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Rank Label
        rankLabel.font = .systemFont(ofSize: 13, weight: .medium)
        rankLabel.textAlignment = .center
        rankLabel.textColor = .secondaryLabel
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        rankLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

        // Icon Image
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 20
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Symbol & Market Cap Stack
        symbolLabel.font = .boldSystemFont(ofSize: 16)
        marketCapLabel.font = .systemFont(ofSize: 12)
        marketCapLabel.textColor = .secondaryLabel
        
        let infoStack = UIStackView(arrangedSubviews: [symbolLabel, marketCapLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Price Label
        priceLabel.font = .systemFont(ofSize: 15, weight: .medium)
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabelContainer = UIView()
        priceLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        priceLabelContainer.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: priceLabelContainer.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: priceLabelContainer.trailingAnchor),
            priceLabel.topAnchor.constraint(equalTo: priceLabelContainer.topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: priceLabelContainer.bottomAnchor)
        ])
        
        // Left Stack
        let leftStack = UIStackView(arrangedSubviews: [rankLabel, iconImageView, infoStack, priceLabelContainer])
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center
        leftStack.distribution = .fill
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.setCustomSpacing(2, after: rankLabel)
        
        // Chart View
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        // Price Change Label
        priceChangeLabel.font = .systemFont(ofSize: 13)
        priceChangeLabel.textAlignment = .center
        priceChangeLabel.numberOfLines = 1
        
        // Right Stack
        let rightStack = UIStackView(arrangedSubviews: [chartView, priceChangeLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .fill
        rightStack.distribution = .fillEqually
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Main Stack
        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            mainStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            infoStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.18),
            priceLabelContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.22),
            chartView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.22)
        ])
    }
}
