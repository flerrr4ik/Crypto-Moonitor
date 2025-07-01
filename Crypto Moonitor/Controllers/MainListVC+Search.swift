//
//  MainListVC+Search.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 17.06.2025.
//

import UIKit

extension MainListVC: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        let searchBase = getSearchBase()
        filterCryptos(searchBase: searchBase, searchText: searchText)
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func getSearchBase() -> [Crypto] {
        if segmentControl.selectedSegmentIndex == 1 {
            let favoriteIds = FavoritesManager.shared.favoriteIds
            return cryptos.filter { favoriteIds.contains($0.id) }
        }
        return cryptos
    }
    
    private func filterCryptos(searchBase: [Crypto], searchText: String) {
        filteredCryptos = searchBase.filter {
            $0.name.lowercased().contains(searchText) ||
            $0.symbol.lowercased().contains(searchText)
        }
        print("🔍 Search: '\(searchText)', found \(filteredCryptos.count)")
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.emptyStateLabel.isHidden = !(self?.isSearching ?? false) || !(self?.filteredCryptos.isEmpty ?? true)
        }
    }
}
