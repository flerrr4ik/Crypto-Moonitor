//
//  DetailedCryptoVC.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.03.2025.
//

import UIKit
import DGCharts
import Charts
import UserNotifications

class DetailedCryptoVC: UIViewController {
    
    // MARK: - Properties
    
    // Views
    let scrollView = UIScrollView()
    let contentView = UIView()

    // Data Models
    var crypto: Crypto?
    var detailedCrypto: DetailedCrypto?
    var exchangeLogos: [String: String] = [:]
    var tickers: [Ticker] = []
    var exchangeURLs: [String: String] = [:]
    
    // Chart Data
    private var currentChartTask: URLSessionDataTask?
    private var isLoadingChart = false
    private var lastChartRequestTime: Date?
    private var chartCache: [TimeRange: [ChartDataEntry]] = [:]
    private var currentTimeRange: TimeRange = .day
    
    // URLs & Descriptions
    private var githubURLString: String?
    private var twitterURLString: String?
    private var redditURLString: String?
    private var webSiteURLString: String?
    private var cryptoDescription: String?
    
    // MARK: - UI Components
    
    // Labels
    private lazy var symbolLabel = UILabel()
    private lazy var priceLabel = UILabel()
    private lazy var priceChangeLabel = UILabel()
    private lazy var marketCapLabel = UILabel()
    private lazy var nameLabel = UILabel()
    private lazy var rankLabel = UILabel()
    private lazy var totalSupplyLabel = UILabel()
    private lazy var circulatingSupplyLabel = UILabel()
    private lazy var volumeLabel = UILabel()
    private lazy var allTimeHighLabel = UILabel()
    private lazy var platformLabel = UILabel()
    private lazy var contractLabel = UILabel()
    
    // ImageViews & Chart
    private let logoImageView = UIImageView()
    private let chartView = LineChartView()
    
    // Buttons
    private let gitHubButton = makeSocialButton(named: "github", title: "   GitHub")
    private let twitterButton = makeSocialButton(named: "twitter", title: "   Twitter")
    private let redditButton = makeSocialButton(named: "reddit", title: "   Reddit")
    private let webSiteButton = makeSocialButton(named: "website", title: "   Website")
    private let favoriteButton = makeButton(named: "notFavorite")
    private let descriptionButton = makeButton(named: "info")
    private let notificationButton = makeButton(named: "notification")
    
    // Controls & Views
    private let timeRangeControl = UISegmentedControl(items: ["1h", "24h", "7d", "30d", "90d"])
    private let infoTableView = UITableView()
    private var priceCheckTimer: Timer?
    var infoRows: [InfoRow] = []
    let notificationManager: NotificationManaging = NotificationService.shared
    
    // Collection Views & Stacks
    private lazy var marketsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 70)
        layout.minimumLineSpacing = 8
        layout.sectionInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MarketCell.self, forCellWithReuseIdentifier: "MarketCell")
        return collectionView
    }()
    
    private lazy var miniDetailStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [symbolLabel, priceChangeLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainDetailStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [miniDetailStack, priceLabel, marketCapLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.layer.cornerRadius = 20
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var labelInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, logoImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [favoriteButton, descriptionButton, notificationButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var socialMediaStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [webSiteButton, twitterButton, redditButton, gitHubButton])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSubviews()
        setupActions()
        setupDelegates()
        setupTableView()
        setupTimeRangeControl()
        setupChartView()
        setupConstraints()
        timeRangeChanged()
        updateFavoritesButton()
        updateNotificationButton()
        setupScrollView()
        
        notificationManager.requestPermission { granted in
            print(granted ? "📬 Allowed" : "❌ Denied")
        }
        
        priceCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkPriceTarget()
        }
        
        guard let crypto = crypto else {
            print("❌ Crypto is nil — cannot proceed")
            return
        }
        
        configureWithCrypto(crypto)
        fetchDetailedInfo(for: crypto.id)
        fetchExchangesAndTickers(for: crypto.id)
        
        if let change = crypto.price_change_percentage_24h {
            updatePriceChange(change)
        }
        loadLogo(from: crypto.image)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyGradientBackground(to: mainDetailStack)
    }
    
    // MARK: - Setup Methods
    
    private func setupSubviews() {
        [mainDetailStack, timeRangeControl, chartView, marketsCollectionView, labelInfoStack, socialMediaStack, infoTableView, buttonsStack].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupActions() {
        gitHubButton.addTarget(self, action: #selector(gitHubButtonTapped), for: .touchUpInside)
        twitterButton.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        redditButton.addTarget(self, action: #selector(redditButtonTapped), for: .touchUpInside)
        webSiteButton.addTarget(self, action: #selector(webSiteButtonTapped), for: .touchUpInside)
        descriptionButton.addTarget(self, action: #selector(descriptionButtonTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoritesButtonTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
 
        [descriptionButton, favoriteButton, notificationButton, webSiteButton, twitterButton, redditButton, gitHubButton].forEach { button in
            button.addTarget(self, action: #selector(self.animateButtonDown(_:)), for: [.touchDown])
            button.addTarget(self, action: #selector(self.animateButtonUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTableView() {
        infoTableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.identifier)
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        infoTableView.backgroundColor = .clear
        infoTableView.isScrollEnabled = false
    }
 
    private func setupDelegates() {
        infoTableView.dataSource = self
        marketsCollectionView.delegate = self
        marketsCollectionView.dataSource = self
    }
    
    private func setupTimeRangeControl() {
        timeRangeControl.selectedSegmentIndex = currentTimeRange.rawValue
        timeRangeControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        timeRangeControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupChartView() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        configureChartAppearance()
        
        let marker = ChartValueMarker(
            color: UIColor.systemIndigo.withAlphaComponent(0.9),
            font: .systemFont(ofSize: 12, weight: .medium),
            textColor: .white,
            insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        )
        marker.chartView = chartView
        chartView.marker = marker
    }
    
    private func configureChartAppearance() {
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .secondaryLabel
        xAxis.gridColor = .systemGray4
        xAxis.avoidFirstLastClippingEnabled = true
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.labelFont = .systemFont(ofSize: 6)
        chartView.leftAxis.labelTextColor = .secondaryLabel
        chartView.leftAxis.gridColor = .systemGray4
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            labelInfoStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelInfoStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),
            
            miniDetailStack.heightAnchor.constraint(equalTo: mainDetailStack.heightAnchor, multiplier: 0.2),
            priceLabel.heightAnchor.constraint(equalTo: mainDetailStack.heightAnchor, multiplier: 0.45),
            marketCapLabel.heightAnchor.constraint(equalTo: mainDetailStack.heightAnchor, multiplier: 0.5),
            
            mainDetailStack.topAnchor.constraint(equalTo: labelInfoStack.bottomAnchor, constant: 12),
            mainDetailStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainDetailStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            mainDetailStack.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.14),
            
            socialMediaStack.topAnchor.constraint(equalTo: mainDetailStack.topAnchor),
            socialMediaStack.leadingAnchor.constraint(equalTo: mainDetailStack.trailingAnchor, constant: 6),
            socialMediaStack.trailingAnchor.constraint(equalTo: buttonsStack.leadingAnchor, constant: -6),
            socialMediaStack.bottomAnchor.constraint(equalTo: mainDetailStack.bottomAnchor),
            
            buttonsStack.topAnchor.constraint(equalTo: socialMediaStack.topAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            buttonsStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.17),
            buttonsStack.heightAnchor.constraint(equalTo: socialMediaStack.heightAnchor),
            
            timeRangeControl.topAnchor.constraint(equalTo: mainDetailStack.bottomAnchor, constant: 12),
            timeRangeControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timeRangeControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            chartView.topAnchor.constraint(equalTo: timeRangeControl.bottomAnchor, constant: 8),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.24),
            
            marketsCollectionView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 2),
            marketsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            marketsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            marketsCollectionView.heightAnchor.constraint(equalTo: contentView.heightAnchor ,multiplier: 0.11),
            
            infoTableView.topAnchor.constraint(equalTo: marketsCollectionView.bottomAnchor, constant: -8),
            infoTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            infoTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        [symbolLabel, priceLabel, priceLabel, priceChangeLabel, marketCapLabel,
         nameLabel, rankLabel, totalSupplyLabel, circulatingSupplyLabel, volumeLabel,
         allTimeHighLabel, platformLabel,
         platformLabel, contractLabel, logoImageView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - UI Factory Methods
    
    private static func makeSocialButton(named: String, title: String) -> UIButton {
        let button = UIButton(type: .system)

        if let image = UIImage(named: named)?.withRenderingMode(.alwaysOriginal) {
            button.setImage(image, for: .normal)
        }
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .leading
        button.semanticContentAttribute = .forceLeftToRight
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 165).isActive = true
        button.backgroundColor = .systemGray5.withAlphaComponent(0.4)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private static func makeButton(named: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: named)
        config.contentInsets = .zero
        config.imagePadding = 0
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear
        config.background.strokeColor = .clear
        config.cornerStyle = .fixed
        config.image = UIImage(named: named)?
            .withRenderingMode(.alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.isExclusiveTouch = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
 
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.imageView?.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.8).isActive = true
        button.imageView?.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.8).isActive = true
     
        return button
    }
    
    private func makeLabel(fontSize: CGFloat = 14, weight: UIFont.Weight = .regular, lines: Int = 1) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.numberOfLines = lines
        return label
    }
    
    // MARK: - Data Configuration
    
    private func configureWithCrypto(_ crypto: Crypto) {
        nameLabel.text = crypto.name
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .label
        rankLabel.text = "\(crypto.market_cap_rank)"
        
        symbolLabel.text = crypto.symbol.uppercased()
        symbolLabel.font = .systemFont(ofSize: 26, weight: .medium)
        
        priceLabel.text = String(format: "%.5f$", crypto.current_price)
        priceLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = .label
        priceLabel.numberOfLines = 0
        priceLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        if let marketCap = crypto.market_cap {
            let billions = Double(marketCap) / 1_000_000_000
            let smallText = NSAttributedString(
                string: "Market Cap:\n",
                attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.label.withAlphaComponent(0.4)])
            
            let bigText = NSAttributedString(
                string: "\(String(format: "$%.2fB", billions))",
                attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
            
            let combined = NSMutableAttributedString()
            combined.append(smallText)
            combined.append(bigText)
            marketCapLabel.numberOfLines = 0
            marketCapLabel.attributedText = combined
        }
        
        if let url = URL(string: crypto.image) {
            logoImageView.sd_setImage(with: url)
        }
    }
    
    // MARK: - Network Methods
    
    private func fetchDetailedInfo(for id: String) {
        APIService.shared.fetchDetail(for: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let detailedCrypto):
                self.processDetailedCrypto(detailedCrypto)
            case .failure(let error):
                print("❌ Failed to fetch detailed info: \(error.localizedDescription)")
            }
        }
    }
    
    private func processDetailedCrypto(_ detailedCrypto: DetailedCrypto) {
        let links = detailedCrypto.links
        let marketData = detailedCrypto.marketData
        let platforms = detailedCrypto.platforms
        
        let github = links?.repos_url.github.first
        let twitter = links?.twitter_screen_name
        let reddit = links?.subreddit_url
        let website = links?.homepage.first
        
        let volume = marketData?.totalVolume?["usd"]
        let totalSupply = marketData?.totalSupply
        let ath = marketData?.ath?["usd"]
        let circulatingSupply = marketData?.circulatingSupply
        
        let platform = platforms?.first(where: { !$0.value.isEmpty })
        let platformName = platform?.key ?? "N/A"
        let contractAddress = platform?.value ?? "N/A"
        
        let percentText: String? = {
            guard let total = totalSupply, let circulating = circulatingSupply, total > 0 else { return nil }
            let percent = (circulating / total) * 100
            return String(format: "%.2f%%", percent)
        }()
        
        let info: [InfoRow] = [
            InfoRow(title: "Rank", value: "\(self.crypto?.market_cap_rank ?? 0)", fullValue: nil),
            InfoRow(title: "Volume", value: volume.map { "$\($0.formatted)" } ?? "N/A", fullValue: nil),
            InfoRow(title: "ATH", value: ath.map { "$\($0.formatted)" } ?? "N/A", fullValue: nil),
            InfoRow(title: "Total Supply", value: totalSupply?.formatted ?? "N/A", fullValue: nil),
            InfoRow(title: "Circulating Supply", value: percentText ?? "N/A", fullValue: nil),
            InfoRow(title: "Platform", value: platformName, fullValue: nil),
            InfoRow(title: "Contract", value: self.truncated(contractAddress), fullValue: contractAddress)
        ]
        
        DispatchQueue.main.async {
            self.githubURLString = github
            self.twitterURLString = twitter.map { "https://twitter.com/\($0)" }
            self.redditURLString = reddit
            self.webSiteURLString = website
            self.cryptoDescription = detailedCrypto.description?.en
            
            self.volumeLabel.text = volume.map { "$\($0.formatted) USD" }
            self.totalSupplyLabel.text = totalSupply?.formatted
            self.allTimeHighLabel.text = ath.map { "$\($0.formatted)" }
            self.platformLabel.text = platformName
            self.contractLabel.text = self.truncated(contractAddress)
            
            self.infoRows = info
            self.infoTableView.reloadData()
        }
    }
    
    private func fetchExchangesAndTickers(for id: String) {
        APIService.shared.fetchExchanges { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let exchanges):
                self.processExchanges(exchanges, for: id)
            case .failure(let error):
                print("❌ Failed to fetch exchanges: \(error.localizedDescription)")
            }
        }
    }
    
    private func processExchanges(_ exchanges: [Exchange], for id: String) {
        DispatchQueue.main.async {
            exchanges.forEach {
                self.exchangeLogos[$0.name] = $0.image
                self.exchangeURLs[$0.name] = $0.url
            }

            APIService.shared.fetchTickers(for: id) { result in
                switch result {
                case .success(let tickers):
                    self.processTickers(tickers)
                case .failure(let error):
                    print("❌ Failed to fetch tickers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func processTickers(_ tickers: [Ticker]) {
        let filtered = tickers.filter {
            self.exchangeLogos[$0.market.name] != nil &&
            self.exchangeURLs[$0.market.name] != nil
        }

        let sorted = filtered.sorted { ($0.volume ?? 0) > ($1.volume ?? 0) }

        var seenExchanges = Set<String>()
        let unique = sorted.filter { seenExchanges.insert($0.market.name).inserted }

        let top10 = Array(unique.prefix(10))

        DispatchQueue.main.async {
            self.tickers = top10
            self.marketsCollectionView.reloadData()
        }
    }
    
    // MARK: - UI Update Methods
    
    private func updatePriceChange(_ change: Double) {
        priceChangeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        let color: UIColor = change >= 0 ? .systemGreen : .systemRed
        priceChangeLabel.textColor = color
        priceLabel.textColor = color

        let arrow = change >= 0 ? " ▲" : " ▼"
        priceChangeLabel.text = String(format: "%.2f%%", change) + arrow

        guard let id = crypto?.id, let name = crypto?.name else { return }

        let key = "alert_\(id)"
        let targetPrice = UserDefaults.standard.double(forKey: key)

        guard let currentPrice = crypto?.current_price else { return }

        if targetPrice > 0 && currentPrice >= targetPrice {
            print("🎯 Target reached: \(currentPrice) >= \(targetPrice)")
            notificationManager.schedulePriceAlert(
                id: id,
                title: name,
                targetPrice: targetPrice
            )
            UserDefaults.standard.removeObject(forKey: key)
            updateNotificationButton()
        }
    }
    
    private func loadLogo(from urlString: String) {
        if let url = URL(string: urlString) {
            logoImageView.sd_setImage(with: url)
        }
    }
    
    private func applyGradientBackground(to view: UIView) {
        let gradientLayer: CAGradientLayer

        if let existing = view.layer.sublayers?.first(where: { $0.name == "fadeGradient" }) as? CAGradientLayer {
            gradientLayer = existing
        } else {
            gradientLayer = CAGradientLayer()
            gradientLayer.name = "fadeGradient"
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.systemGray.withAlphaComponent(0.08).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.cornerRadius = view.layer.cornerRadius
            view.layer.insertSublayer(gradientLayer, at: 0)
        }

        gradientLayer.frame = view.bounds
    }
    
    private func updateFavoritesButton() {
        favoriteButton.layer.shadowOpacity = 0
        guard let cryptoId = crypto?.id else { return }
        let isFavorite = FavoritesManager.shared.isFavorite(id: cryptoId)
        let imageName = isFavorite ? "favorite" : "notFavorite"
        UIView.performWithoutAnimation {
            favoriteButton.setImage(UIImage(named: imageName), for: .normal)
            favoriteButton.layoutIfNeeded()
        }
    }
    
    private func updateNotificationButton() {
        guard let cryptoID = crypto?.id else { return }
        let key = "alert_\(cryptoID)"
        let alertPrice = UserDefaults.standard.double(forKey: key)
        
        let imageName = alertPrice > 0 ? "notificationOn" : "notification"
        UIView.transition(with: notificationButton, duration: 0.25, animations: {
            self.notificationButton.setImage(UIImage(named: imageName), for: .normal)
        })
    }
    
    // MARK: - Timer Methods
    
    private func checkPriceTarget() {
        guard let id = crypto?.id else { return }
        let key = "alert_\(id)"
        let target = UserDefaults.standard.double(forKey: key)

        guard target > 0 else { return }

        APIService.shared.fetchPrice(for: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success ( let newPrice) :
                
                priceLabel.text = String(format: "%.5f$", newPrice)
                DispatchQueue.main.async {
                    print("New price: \(newPrice), target: \(target)")
                    if newPrice >= target {
                        self.triggerNotification(for: id, price: newPrice)
                    }
                }
            case .failure(let error):
                print("❌ Failed to check price: \(error.localizedDescription)")
            }
        }
    }

    private func triggerNotification(for id: String, price: Double) {
        guard let name = crypto?.name else { return }

        notificationManager.schedulePriceAlert(
            id: id,
            title: name,
            targetPrice: price
        )

        UserDefaults.standard.removeObject(forKey: "alert_\(id)")
        updateNotificationButton()
        print("Notification triggered for \(id) at $\(price)")
    }
    
    // MARK: - Helper Methods
    
    func truncated(_ text: String, length: Int = 10) -> String {
        if text.count <= length { return text }
        let prefix = text.prefix(6)
        let suffix = text.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    // MARK: - Action Methods
    
    @objc private func timeRangeChanged() {
        print("📍 Segmented control changed to index:", timeRangeControl.selectedSegmentIndex)
        
        guard let newRange = TimeRange(rawValue: timeRangeControl.selectedSegmentIndex) else {
            print("❌ Invalid segment index")
            return
        }
        guard let crypto = crypto?.id else { return }
        currentTimeRange = newRange
        print("📊 Changing chart to range:", newRange)
       
        ChartService.shared.loadAndDisplayChart(
            for: crypto,
            in: currentTimeRange,
            using: chartView,
            cache: chartCache
        ) { [weak self] updatedCache in
            self?.chartCache = updatedCache
            self?.chartView.xAxis.valueFormatter = DateValueFormatter(range: self?.currentTimeRange ?? .day)
        }
    }
    
    @objc private func gitHubButtonTapped() {
        guard let urlString = githubURLString,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func twitterButtonTapped() {
        guard let urlString = twitterURLString,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func redditButtonTapped() {
        guard let urlString = redditURLString,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func webSiteButtonTapped() {
        guard let urlString = webSiteURLString,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func descriptionButtonTapped() {
        let textVC = DescriptionView()
        textVC.textView.text = cryptoDescription
        textVC.modalPresentationStyle = .pageSheet
        
        if let sheet = textVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 1200 })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30
        }
        present(textVC, animated: true)
    }
    
    @objc func favoritesButtonTapped() {
        guard let cryptoId = crypto?.id else { return }
        
        if FavoritesManager.shared.isFavorite(id: cryptoId) {
            FavoritesManager.shared.removeFavorite(id: cryptoId)
        } else {
            FavoritesManager.shared.addFavorite(id: cryptoId)
        }
        updateFavoritesButton()
    }
    
    @objc private func notificationButtonTapped() {
        guard let cryptoID = crypto?.id else { return }
        let key = "alert_\(cryptoID)"
        let currentTarget = UserDefaults.standard.double(forKey: key)

        if currentTarget > 0 {
            let alert = UIAlertController(title: "Delete notification?", message: "Target price: $\(currentTarget)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                UserDefaults.standard.removeObject(forKey: key)
                self.updateNotificationButton()
                print("Notification deleted")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "Enter Target Price", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "For example: 2000"
                textField.keyboardType = .decimalPad
            }

            let confirm = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alert] _ in
                guard let self = self,
                      let text = alert?.textFields?.first?.text?.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines),
                      let targetPrice = Double(text), targetPrice > 0 else {
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                    
                    let errorAlert = UIAlertController(title: "Wrong value", message: "", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(errorAlert, animated: true)
                    return
                }

                UserDefaults.standard.set(targetPrice, forKey: key)
                self.updateNotificationButton()
                print("🔔 Notification set for \(cryptoID) at $\(targetPrice)")
            }

            alert.addAction(confirm)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @objc private func animateButtonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: .allowUserInteraction,
                       animations: {
                           sender.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                       },
                       completion: nil)
    }

    @objc private func animateButtonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 6,
                       options: .allowUserInteraction,
                       animations: {
                           sender.transform = .identity
                       },
                       completion: nil)
    }
}
