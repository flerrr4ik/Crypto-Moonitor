//
//  NotificationService.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

import Foundation
import UserNotifications

final class NotificationService: NotificationManaging {
    
    // MARK: - Singleton Instance
    
    static let shared = NotificationService()
    private init() {}
    
    // MARK: - Private Properties
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Notification Authorization
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification permission error:", error)
            }
            completion(granted)
        }
    }
    
    // MARK: - Price Alert Management
    
    func schedulePriceAlert(id: String, title: String, targetPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "\(title) reached \(targetPrice)$"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "alert_\(id)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Scheduling notification error:", error)
            }
        }
    }
    
    func removePriceAlert(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["alert_\(id)"])
    }
    
    // MARK: - Debug Utilities
    
    func listPendingAlerts() {
        center.getPendingNotificationRequests { requests in
            print("📬 Pending notifications:")
            requests.forEach { print("•", $0.identifier) }
        }
    }
}
