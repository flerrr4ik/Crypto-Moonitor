//
//  DeteiledCryptoVC.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit
import DGCharts
import Charts
import UserNotifications

class DetailedCryptoVC: UIViewController {
    
    // MARK: - Models
    
    var crypto: Crypto?
    var detailedCrypto: DetailedCrypto?
    var exchangeLogos: [String: String] = [:]
    var tickers: [Ticker] = []
    var exchangeURLs: [String: String] = [:]
    
    
    // MARK: - Chart & Time Range
    
    private var currentChartTask: URLSessionDataTask?
    private var isLoadingChart = false
    private var lastChartRequestTime: Date?
    private var chartCache: [TimeRange: [ChartDataEntry]] = [:]
    private var currentTimeRange: TimeRange = .day

    
    // MARK: - Strings
    
    private var githubURLString: String?
    private var twitterURLString: String?
    private var redditURLString: String?
    private var webSiteURLString: String?
    private var cryptoDescription: String?
    
    // MARK: - Labels
    
    private let symbolLabel = UILabel()
    private let priceLabel = UILabel()
    private let priceChangeLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let nameLabel = UILabel()
    private let rankLabel = UILabel()
    private let totalSupplyLabel = UILabel()
    private let circulatingSupplyLabel = UILabel()
    private let volumeLabel = UILabel()
    private let allTimeHighLabel = UILabel()
    private let platformLabel = UILabel()
    private let contractLabel = UILabel()
    
    // MARK: - ImageViews & Chart
    
    private let logoImageView = UIImageView()
    private let chartView = LineChartView()
    
    // MARK: - Buttons
    
    private let gitHubButton = makeSocialButton(named: "github", title: "   GitHub")
    private let twitterButton = makeSocialButton(named: "twitter", title: "   Twitter")
    private let redditButton = makeSocialButton(named: "reddit", title: "   Reddit")
    private let webSiteButton = makeSocialButton(named: "website", title: "   Website")
    
    private let favoriteButton = makeButton(named: "notFavorite")
    private let descriptionButton = makeButton(named: "info")
    private let notificationButton = makeButton(named: "notification")
    
    // MARK: - Controls & Views
    
    private let timeRangeControl = UISegmentedControl(items: ["1h", "24h", "7d", "30d", "90d"])
    private let infoTableView = UITableView()
    var infoRows: [InfoRow] = []
    private var priceCheckTimer: Timer?
    
    // MARK: - Stacks & CollectonView
    
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
        let stack = UIStackView(arrangedSubviews: [symbolLabel, priceChangeLabel,])
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
        stack.alignment = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var socialMediaStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [webSiteButton, twitterButton, redditButton, gitHubButton])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let fadeMask = CAGradientLayer()
    
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
        
        
        
        NotificationService.shared.requestPermission { granted in
            print(granted ? "📬 Allowed" : "❌ Denied")
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
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientBackground(to: mainDetailStack)
    }
    private func setupSubviews() {
        [mainDetailStack, timeRangeControl, chartView, marketsCollectionView, labelInfoStack, socialMediaStack, infoTableView, buttonsStack].forEach {
            view.addSubview($0)
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
    private func configureWithCrypto(_ crypto: Crypto) {
        nameLabel.text = crypto.name
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .label
        rankLabel.text = "\(crypto.market_cap_rank)"
        
        symbolLabel.text = crypto.symbol.uppercased()
        symbolLabel.font = .systemFont(ofSize: 26, weight: .medium)
        
        priceLabel.text = String(format: "%.2f$", crypto.current_price)
        priceLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        priceLabel.textColor = .label
        priceLabel.numberOfLines = 0
        priceLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        
        if let marketCap = crypto.market_cap {
            let billions = Double(marketCap) / 1_000_000_000
            let smallText = NSAttributedString(
                string: "Market Cap:\n",
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.label.withAlphaComponent(0.4)] )
            
            let bigText = NSAttributedString(
                string:  "\(String(format: "$%.2fB", billions))",
                attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)] )
            
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

        if targetPrice > 0 {
            NotificationService.shared.removePriceAlert(id: id)
        } else if change >= 0 && priceLabel.text.flatMap(Double.init) ?? 0 >= targetPrice {
            NotificationService.shared.schedulePriceAlert(
                id: id,
                title: name,
                targetPrice: targetPrice
            )
        }
    }
    
    private func loadLogo(from urlString: String) {
        if let url = URL(string: urlString) {
            logoImageView.sd_setImage(with: url)
        }
    }
    
    func truncated(_ text: String, length: Int = 10) -> String {
        if text.count <= length { return text }
        let prefix = text.prefix(6)
        let suffix = text.suffix(4)
        return "\(prefix)...\(suffix)"
        
    }
    
    private func fetchDetailedInfo(for id: String) {
        APIService.shared.fetchDetail(for: id) { [weak self] detailedCrypto in
            guard let self = self, let detailedCrypto = detailedCrypto else { return }

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

            // Гарантовано зберігаємо порядок відображення
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
    }
    
    private func fetchExchangesAndTickers(for id: String) {
        APIService.shared.fetchExchanges { [weak self] exchanges in
            guard let self = self, let exchanges = exchanges else { return }
            
            DispatchQueue.main.async {
                exchanges.forEach {
                    self.exchangeLogos[$0.name] = $0.image
                    self.exchangeURLs[$0.name] = $0.url
                }
                print("Exchanges: \(self.exchangeLogos.count), tickers before filtering: \(exchanges.count)")
                
                APIService.shared.fetchTickers(for: id) { result in
                    guard let result = result else { return }
                    let filtered = result.filter {
                        self.exchangeLogos[$0.market.name] != nil &&
                        self.exchangeURLs[$0.market.name] != nil
                    }
                    let sorted = filtered.sorted { ($0.volume ?? 0) > ($1.volume ?? 0) }

                    var seenExchanges = Set<String>()
                    let unique = sorted.filter { seenExchanges.insert($0.market.name).inserted }

                    let top10 = Array(unique.prefix(10))
                    
                    print("Filtered tickers count: \(unique.count)")
                    DispatchQueue.main.async {
                        self.tickers = top10
                        self.marketsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            labelInfoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            labelInfoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            miniDetailStack.heightAnchor.constraint(equalToConstant: 30),
            
            marketCapLabel.heightAnchor.constraint(equalToConstant: 50),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),
            
            descriptionButton.widthAnchor.constraint(equalToConstant: 40),
            descriptionButton.heightAnchor.constraint(equalToConstant: 40),
            
            notificationButton.widthAnchor.constraint(equalToConstant: 40),
            notificationButton.heightAnchor.constraint(equalToConstant: 40),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            
            buttonsStack.topAnchor.constraint(equalTo: socialMediaStack.topAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: socialMediaStack.trailingAnchor, constant: 12),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: socialMediaStack.bottomAnchor ),
            
            mainDetailStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainDetailStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainDetailStack.widthAnchor.constraint(equalToConstant: 155),
            
            socialMediaStack.topAnchor.constraint(equalTo: mainDetailStack.topAnchor, constant: 0),
            socialMediaStack.leadingAnchor.constraint(equalTo: mainDetailStack.trailingAnchor, constant: 24),
            socialMediaStack.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            socialMediaStack.bottomAnchor.constraint(equalTo: mainDetailStack.bottomAnchor, constant: 0),
            
            gitHubButton.heightAnchor.constraint(equalToConstant: 30),
            gitHubButton.widthAnchor.constraint(equalToConstant: 165),
            
            twitterButton.heightAnchor.constraint(equalToConstant: 30),
            twitterButton.widthAnchor.constraint(equalToConstant: 165),
            
            redditButton.heightAnchor.constraint(equalToConstant: 30),
            redditButton.widthAnchor.constraint(equalToConstant: 165),
            
            webSiteButton.heightAnchor.constraint(equalToConstant: 30),
            webSiteButton.widthAnchor.constraint(equalToConstant: 165),
            
            timeRangeControl.topAnchor.constraint(equalTo: mainDetailStack.bottomAnchor, constant: 16),
            timeRangeControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timeRangeControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeRangeControl.heightAnchor.constraint(equalToConstant: 32),
            
            chartView.topAnchor.constraint(equalTo: timeRangeControl.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.24),
            
            marketsCollectionView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 2),
            marketsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            marketsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            marketsCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            infoTableView.topAnchor.constraint(equalTo: marketsCollectionView.bottomAnchor, constant: 0),
            infoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private static func makeSocialButton(named: String, title: String) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(named: named)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.tintColor = .systemBlue
        button.setTitleColor(.systemGray, for: .normal)
        button.backgroundColor = .systemGray.withAlphaComponent(0.08)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .leading
        button.semanticContentAttribute = .forceLeftToRight
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
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

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isExclusiveTouch = true
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center

        return button
    }
    private func applyGradientBackground(to view: UIView) {

        if let sublayers = view.layer.sublayers,
           sublayers.contains(where: { $0.name == "fadeGradient" }) {
            return
        }
        
        let gradient = CAGradientLayer()
        gradient.name = "fadeGradient"
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.systemGray.withAlphaComponent(0.08).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = view.bounds
        gradient.cornerRadius = view.layer.cornerRadius
        
        view.layer.insertSublayer(gradient, at: 0)
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
