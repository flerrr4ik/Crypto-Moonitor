//
//  MainListVC+TableView.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 17.06.2025.
//

import UIKit

extension MainListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let displayedCryptos: [Crypto]
        
        if segmentControl.selectedSegmentIndex == 1 {
            let favoriteIds = FavoritesManager.shared.favoriteIds
            displayedCryptos = cryptos.filter { favoriteIds.contains($0.id) }
        } else {
            displayedCryptos = cryptos
        }
        
        return isSearching ? filteredCryptos.count : displayedCryptos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath) as! CryptoCell
        
        let crypto: Crypto
        if isSearching {
            crypto = filteredCryptos[indexPath.row]
        } else {
            if segmentControl.selectedSegmentIndex == 1 {
                let favoriteIds = FavoritesManager.shared.favoriteIds
                let favoriteCryptos = cryptos.filter { favoriteIds.contains($0.id) }
                crypto = favoriteCryptos[indexPath.row]
            } else {
                crypto = cryptos[indexPath.row]
            }
        }
        
        cell.configureBasicInfo(with: crypto)
        if let sparkline = crypto.sparkline_in_7d?.price {
            cell.loadChart(with: sparkline.map { CGFloat($0) })
        } else {
            cell.loadChart(with: [])
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let crypto = isSearching ? filteredCryptos[indexPath.row] : cryptos[indexPath.row]
        let detailVC = DetailedCryptoVC()
        detailVC.crypto = crypto
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
