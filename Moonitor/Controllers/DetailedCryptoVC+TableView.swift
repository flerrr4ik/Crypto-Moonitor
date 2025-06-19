//
//  DetailedCryptoVC+TableView.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 16.06.2025.
//

import UIKit

extension DetailedCryptoVC: UITableViewDataSource, UITabBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as? InfoCell else {
            return UITableViewCell()
        }
        let item = infoRows[indexPath.row]
        cell.configure(with: item)
        cell.selectionStyle = .none
        return cell
    }
}
