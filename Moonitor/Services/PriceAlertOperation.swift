//
//  CryptoFetchOperation.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import Foundation
import UserNotifications

final class PriceAlertOperation: Operation, @unchecked Sendable {
    private let cryptoID: String
    private let targetPrice: Double
    
    init(cryptoID: String, targetPrice: Double) {
        self.cryptoID = cryptoID
        self.targetPrice = targetPrice
    }
    
    override func main() {
        if isCancelled { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        APIService.shared.fetchCryptoByID(id: cryptoID) { crypto in
            defer { semaphore.signal() }
            
            guard let crypto = crypto else {
                print("❌ Failed to fetch \(self.cryptoID)")
                return
            }
            
            print("✅ Price for \(crypto.name): \(crypto.current_price)$")
            
            if crypto.current_price >= self.targetPrice {
                self.sendPushNotification(for: crypto)
            }
        }
        
        semaphore.wait()
    }
    
    private func sendPushNotification(for crypto: Crypto) {
        let content = UNMutableNotificationContent()
        content.title = "\(crypto.name) досяг таргету!"
        content.body = "Ціна: \(crypto.current_price)$ (таргет: \(targetPrice)$)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // показати одразу
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error:", error)
            } else {
                print("🔔 Notification scheduled!")
            }
        }
    }
}
