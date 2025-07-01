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
    
    // MARK: - Configuration
    
    func configureBasicInfo(with crypto: Crypto) {
        // Basic info
        rankLabel.text = "\(crypto.market_cap_rank)"
        symbolLabel.text = crypto.symbol.uppercased()
        
        // Price change
        if let change = crypto.price_change_percentage_24h {
            priceChangeLabel.text = String(format: "%.2f%%", change)
            if change >= -0.01 {
                priceChangeLabel.textColor = .systemGreen
                chartView.setColor(.systemGreen)
            } else {
                priceChangeLabel.textColor = .systemRed
                chartView.setColor(.systemRed)
            }
        } else {
            priceChangeLabel.text = "24h: N/A"
            priceChangeLabel.textColor = .gray
            chartView.setColor(.gray)
        }
        
        // Market cap
        if let marketCap = crypto.market_cap {
            marketCapLabel.text = String(format: "$%.2fB", Double(marketCap) / 1_000_000_000)
        } else {
            marketCapLabel.text = "Market Cap: N/A"
        }
        
        // Price formatting
        priceLabel.text = crypto.current_price < 1 ?
            String(format: "$%.6f", crypto.current_price) :
            String(format: "$%.2f", crypto.current_price)
        
        // Image loading
        if let url = URL(string: crypto.image) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
        }
    }
    
    func loadChart(with prices: [CGFloat]) {
        prices.isEmpty ? chartView.setEmpty() : chartView.setData(prices)
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        // Rank label setup
        rankLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rankLabel.textColor = .secondaryLabel
        rankLabel.textAlignment = .center
        rankLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true

        
        // Icon image setup
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 20
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Symbol labels setup
        symbolLabel.font = .boldSystemFont(ofSize: 16)
        marketCapLabel.font = .systemFont(ofSize: 12)
        marketCapLabel.textColor = .secondaryLabel
        
        // Info stack (symbol + market cap)
        let infoStack = UIStackView(arrangedSubviews: [symbolLabel, marketCapLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.setContentHuggingPriority(.required, for: .horizontal)
        infoStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        infoStack.widthAnchor.constraint(lessThanOrEqualToConstant: 70).isActive = true
        
        // Price label setup
        priceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        priceLabel.textAlignment = .center
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        // Price label container
        let priceLabelContainer = UIView()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabelContainer.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: priceLabelContainer.leadingAnchor, constant: -4),
            priceLabel.topAnchor.constraint(equalTo: priceLabelContainer.topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: priceLabelContainer.bottomAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: priceLabelContainer.trailingAnchor)
        ])
        
        // Left stack (rank + icon + info + price)
        let leftStack = UIStackView(arrangedSubviews: [rankLabel, iconImageView, infoStack, priceLabelContainer])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 8
        leftStack.setContentHuggingPriority(.required, for: .horizontal)
        leftStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Chart setup
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        chartView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        chartView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        chartView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Price change label
        priceChangeLabel.font = .systemFont(ofSize: 13)
        priceChangeLabel.textAlignment = .center
        priceChangeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Right stack (chart + price change)
        let rightStack = UIStackView(arrangedSubviews: [chartView, priceChangeLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 4
        rightStack.alignment = .fill
        rightStack.distribution = .fillEqually
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 24
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        mainStack.tintColor = UIColor(named: "AccentColor")
        
        // Main constraints
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
