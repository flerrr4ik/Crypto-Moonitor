//
//  MainListVC+TableView.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 17.06.2025.
//

import UIKit

extension MainListVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let displayedCryptos = getDisplayedCryptos()
        return isSearching ? filteredCryptos.count : displayedCryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        
        let crypto = getCrypto(for: indexPath)
        configureCell(cell, with: crypto)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let crypto = getCrypto(for: indexPath)
        showDetailViewController(for: crypto)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - Private Methods
    
    private func getDisplayedCryptos() -> [Crypto] {
        if segmentControl.selectedSegmentIndex == 1 {
            let favoriteIds = FavoritesManager.shared.favoriteIds
            return cryptos.filter { favoriteIds.contains($0.id) }
        }
        return cryptos
    }
    
    private func getCrypto(for indexPath: IndexPath) -> Crypto {
        if isSearching {
            return filteredCryptos[indexPath.row]
        }
        
        let displayedCryptos = getDisplayedCryptos()
        return displayedCryptos[indexPath.row]
    }
    
    private func configureCell(_ cell: CryptoCell, with crypto: Crypto) {
        cell.configureBasicInfo(with: crypto)
        
        let sparklineData = crypto.sparkline_in_7d?.price.map { CGFloat($0) } ?? []
        cell.loadChart(with: sparklineData)
    }
    
    private func showDetailViewController(for crypto: Crypto) {
        let detailVC = DetailedCryptoVC()
        detailVC.crypto = crypto
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
