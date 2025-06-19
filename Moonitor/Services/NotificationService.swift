//
//  NotificationService.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: Request Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification permission error:", error)
            }
            completion(granted)
        }
    }
    
    // 🔔 Запланувати сповіщення на задану ціль
    func schedulePriceAlert(id: String, title: String, targetPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "\(title) досяг \(targetPrice)$"
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
    
    // 🗑 Видалити заплановане сповіщення
    func removePriceAlert(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["alert_\(id)"])
    }
    
    // 🧾 Покажчик очікуваних сповіщень (для діагностики)
    func listPendingAlerts() {
        center.getPendingNotificationRequests { requests in
            print("📬 Pending notifications:")
            requests.forEach { print("•", $0.identifier) }
        }
    }
}
