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
    
    // MARK: - Segmented Control
    lazy var segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All Cryptos", "Favorites"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        control.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
        return control
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    
        [segmentControl,tableView, emptyStateLabel, numberStack, marketCapStack, priceStack, priceChangeStack].forEach {view.addSubview($0)}
                                                                                                                      
        setupConstraints()
        setupTableViewAndTitle()
        setupSearchController()
        fetchData()
        
        sortByNumberButton.addTarget(self, action: #selector(sortByNumberButtonTapped), for: .touchUpInside)
        sortByPriceButton.addTarget(self, action: #selector(sortByPriceButtonTapped), for: .touchUpInside)
        sortByMarketCapButton.addTarget(self, action: #selector(sortByMarketCapButtonTapped), for: .touchUpInside)
        sortBy24hPriceChangeButton.addTarget(self, action: #selector(sortBy24hPriceChangeButtonButton), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private static func makeSortButtons(label: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor.systemIndigo.withAlphaComponent(0.6), for: .normal)
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
    private func setupConstraints() {
        NSLayoutConstraint.activate([

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
            
            numberStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            
            marketCapStack.leadingAnchor.constraint(equalTo: numberStack.trailingAnchor, constant: 62),
            marketCapStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            
            priceStack.trailingAnchor.constraint(equalTo: priceChangeStack.leadingAnchor, constant: -68),
            priceStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            
            priceChangeStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            priceChangeStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            
            tableView.topAnchor.constraint(equalTo: numberStack.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            numberStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.07),
            marketCapStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.13),
            priceStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.12),
            priceChangeStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.1),
        ])
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        numberStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceChangeStack.translatesAutoresizingMaskIntoConstraints = false
        marketCapStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cryptocurrencies"
        searchController.searchBar.searchTextField.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableViewAndTitle() {
        title = "Cryptocurrencies"
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.systemIndigo.withAlphaComponent(0.5)]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CryptoCell.self, forCellReuseIdentifier: "CryptoCell")
        tableView.separatorColor = UIColor.systemIndigo.withAlphaComponent(0.9)
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 60
    }
    
    // MARK: - Data Methods
    private func fetchData() {
        print("📡 fetchData started")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            APIService.shared.fetchCryptos { result in
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

