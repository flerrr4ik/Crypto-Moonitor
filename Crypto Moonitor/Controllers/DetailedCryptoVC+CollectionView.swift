//
//  DetailedCryptoVC+CollectionView.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 16.06.2025.
//

import UIKit

extension DetailedCryptoVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ticker = tickers[indexPath.item]
        let logoURL = exchangeLogos[ticker.market.name]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketCell", for: indexPath) as! MarketCell
        cell.configure(with: ticker, logoURL: logoURL)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ticker = tickers[indexPath.item]
        let name = ticker.market.name
        
        if let urlString = exchangeURLs[name], let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        } else {
            print("No URL found for exchange \(name)")
        }
    }
    
    // MARK: - Cell Highlight Animation
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1) {
                cell.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 3,
                           options: .allowUserInteraction,
                           animations: {
                               cell.transform = .identity
                           },
                           completion: nil)
        }
    }
}
