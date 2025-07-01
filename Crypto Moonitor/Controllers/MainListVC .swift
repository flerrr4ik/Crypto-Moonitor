//
//  MainListVC.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit
import SDWebImage
import DGCharts

class MainListVC: UIViewController {
    
    // MARK: - UI Elements
    let tableView = UITableView()
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Data Properties
    var cryptos: [Crypto] = []
    var filteredCryptos: [Crypto] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - Sort State Properties
    private var isSortByNumberAscending = true
    private var isSortByMarketCapAscending = true
    private var isSortByPriceAscending = true
    private var isSortBy24hChangeAscending = true
    
    // MARK: - Sort UI Elements
    private let sortByNumberButton = makeSortButtons(label: "#")
    private let sortByMarketCapButton = makeSortButtons(label: "M.Cap")
    private let sortByPriceButton = makeSortButtons(label: "Price")
    private let sortBy24hPriceChangeButton = makeSortButtons(label: "24h")
    
    private let numberArrowImageView = makeArrowView(image: "arrow.down")
    private let marketCapArrowImageView = makeArrowView(image: "arrow.down")
    private let priceArrowImageView = makeArrowView(image: "arrow.down")
    private let priceChangeArrowImageView = makeArrowView(image: "arrow.down")
    
    // MARK: - Stack Views
    lazy var numberStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sortByNumberButton, numberArrowImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    lazy var marketCapStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sortByMarketCapButton, marketCapArrowImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    lazy var priceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sortByPriceButton, priceArrowImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    lazy var priceChangeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sortBy24hPriceChangeButton, priceChangeArrowImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    lazy var spacer1 = UIView()
    lazy var spacer2 = UIView()
    lazy var spacer3 = UIView()
    
    lazy var sortButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            numberStack, spacer1,
            marketCapStack, spacer2,
            priceStack, spacer3,
            priceChangeStack ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Segmented Control
    lazy var segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All Cryptos", "Favorites"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
        return control
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(segmentControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(sortButtonsStack)
        setupConstaints()
        
        sortByNumberButton.addTarget(self, action: #selector(sortByNumberButtonTapped), for: .touchUpInside)
        sortByPriceButton.addTarget(self, action: #selector(sortByPriceButtonTapped), for: .touchUpInside)
        sortByMarketCapButton.addTarget(self, action: #selector(sortByMarketCapButtonTapped), for: .touchUpInside)
        sortBy24hPriceChangeButton.addTarget(self, action: #selector(sortBy24hPriceChangeButtonButton), for: .touchUpInside)
        
        title = "Cryptocurrencies"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CryptoCell.self, forCellReuseIdentifier: "CryptoCell")
        
        setupSearchController()
        fetchData()
    }
    
    // MARK: - Helper Methods
    private static func makeSortButtons(label: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor.gray.withAlphaComponent(0.6), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private static func makeArrowView(image: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: image))
        imageView.tintColor = .systemBlue
        imageView.alpha = 0.0
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    // MARK: - Setup Methods
    private func setupConstaints() {
        NSLayoutConstraint.activate([
            spacer1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            spacer2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.14),
            spacer3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            
            numberArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            numberArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            priceArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            priceArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            marketCapArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            marketCapArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            priceChangeArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            priceChangeArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            sortByNumberButton.widthAnchor.constraint(equalToConstant: 12),
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sortButtonsStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            sortButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            sortButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            sortButtonsStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.03),
            
            tableView.topAnchor.constraint(equalTo: sortButtonsStack.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            numberStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.07),
            marketCapStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.13),
            priceStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),
            priceChangeStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
        ])
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        sortButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceChangeStack.translatesAutoresizingMaskIntoConstraints = false
        marketCapStack.translatesAutoresizingMaskIntoConstraints = false
        sortByNumberButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cryptocurrencies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Methods
    private func fetchData() {
        print("📡 fetchData started")
        
        APIService.shared.fetchCryptos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let cryptos):
                print("✅ fetchCryptos finished: \(cryptos.count) items")
                self.cryptos = cryptos
                self.filteredCryptos = cryptos
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print("❌ Failed to load cryptos: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Action Methods
    @objc private func segmentControlChanged() {
        tableView.reloadData()
    }
    
    @objc private func sortByNumberButtonTapped() {
        isSortByNumberAscending.toggle()
        cryptos.sort { isSortByNumberAscending ? $0.market_cap_rank < $1.market_cap_rank : $0.market_cap_rank > $1.market_cap_rank }
        updateArrowIndicators(selected: numberArrowImageView, ascending: isSortByNumberAscending)
        tableView.reloadData()
    }
    
    @objc private func sortByPriceButtonTapped() {
        isSortByPriceAscending.toggle()
        cryptos.sort { isSortByPriceAscending ? $0.current_price < $1.current_price : $0.current_price > $1.current_price }
        updateArrowIndicators(selected: priceArrowImageView, ascending: isSortByPriceAscending)
        tableView.reloadData()
    }
    
    @objc private func sortByMarketCapButtonTapped() {
        isSortByMarketCapAscending.toggle()
        cryptos.sort { isSortByMarketCapAscending ? $0.market_cap ?? 0 < $1.market_cap ?? 0 : $0.market_cap ?? 0 > $1.market_cap ?? 0 }
        updateArrowIndicators(selected: marketCapArrowImageView, ascending: isSortByMarketCapAscending)
        tableView.reloadData()
    }
    
    @objc func sortBy24hPriceChangeButtonButton() {
        isSortBy24hChangeAscending.toggle()
        cryptos.sort { isSortBy24hChangeAscending ? $0.price_change_percentage_24h ?? 0 < $1.price_change_percentage_24h ?? 0 : $0.price_change_percentage_24h ?? 0 > $1.price_change_percentage_24h ?? 0 }
        updateArrowIndicators(selected: priceChangeArrowImageView, ascending: isSortBy24hChangeAscending)
        tableView.reloadData()
    }
    
    // MARK: - UI Update Methods
    private func updateArrowIndicators(selected: UIImageView, ascending: Bool) {
        let allArrows = [numberArrowImageView, priceArrowImageView, marketCapArrowImageView, priceChangeArrowImageView]
        for arrow in allArrows {
            arrow.alpha = arrow == selected ? 1.0 : 0.0
        }
        selected.image = UIImage(systemName: ascending ? "arrow.down" : "arrow.up")
    }
}
