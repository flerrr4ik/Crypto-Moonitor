//
//  NotificationManaging.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 25.06.2025.
//

import Foundation

protocol NotificationManaging {
    func requestPermission(completion: @escaping (Bool) -> Void)
    func schedulePriceAlert(id: String, title: String, targetPrice: Double)
    func removePriceAlert(id: String)
    func listPendingAlerts()
}
