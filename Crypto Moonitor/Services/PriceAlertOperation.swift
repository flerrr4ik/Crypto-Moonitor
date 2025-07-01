//
//  PriceAlertOperation.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

import UIKit
final class PriceAlertOperation: Operation, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let cryptoID: String
    private let targetPrice: Double
    private let notificationManager: NotificationManaging
    
    // MARK: - Initialization
    
    init(cryptoID: String, targetPrice: Double, notificationManager: NotificationManaging) {
        self.cryptoID = cryptoID
        self.targetPrice = targetPrice
        self.notificationManager = notificationManager
    }
    
    // MARK: - Main Execution
    
    override func main() {
        if isCancelled { return }

        let semaphore = DispatchSemaphore(value: 0)

        APIService.shared.fetchCryptoByID(cryptoID) { [weak self] result in
            defer { semaphore.signal() }

            guard let self = self else { return }

            switch result {
            case .success(let crypto):
                print("✅ Price for \(crypto.name): \(crypto.current_price)$")

                if crypto.current_price >= self.targetPrice {
                    self.notificationManager.schedulePriceAlert(
                        id: self.cryptoID,
                        title: crypto.name,
                        targetPrice: self.targetPrice
                    )
                }

            case .failure(let error):
                print("❌ Failed to fetch \(self.cryptoID): \(error.localizedDescription)")
            }
        }

        semaphore.wait()
    }
}
