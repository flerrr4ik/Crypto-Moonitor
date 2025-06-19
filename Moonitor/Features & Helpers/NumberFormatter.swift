//
//  NumberFormatter.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 13.06.2025.
//

import Foundation

extension Double {
    var formatted: String {
        let formatted = NumberFormatter()
        formatted.locale = Locale(identifier: "en_US")
        formatted.numberStyle = .decimal
        formatted.maximumFractionDigits = 10
        return formatted.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
