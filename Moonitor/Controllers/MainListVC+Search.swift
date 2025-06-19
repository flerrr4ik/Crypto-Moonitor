//
//  MainListVC+Search.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 17.06.2025.
//

import UIKit

extension MainListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let searchBase: [Crypto]
        
        if segmentControl.selectedSegmentIndex == 1 {
            let favoriteIds = FavoritesManager.shared.favoriteIds
            searchBase = cryptos.filter { favoriteIds.contains($0.id) }
        } else {
            searchBase = cryptos
        }
        
        filteredCryptos = searchBase.filter { crypto in
            crypto.name.lowercased().contains(searchText.lowercased()) ||
            crypto.symbol.lowercased().contains(searchText.lowercased())
        }
        
        print("🔍 Search: '\(searchText)', found \(filteredCryptos.count)")
        tableView.reloadData()
        emptyStateLabel.isHidden = !(isSearching && filteredCryptos.isEmpty)
    }
}
