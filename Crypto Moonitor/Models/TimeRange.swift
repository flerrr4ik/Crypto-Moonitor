//
//  TimeRange.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

enum TimeRange: Int, CaseIterable {
    case hour = 0, day, week, month, threeMonths
    var daysParameter: String {
        switch self {
        case .hour: return "1"
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .threeMonths: return "90"
        }
    }
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .hour: return "1h"
        case .day: return "24h"
        case .week: return "7d"
        case .month: return "30d"
        case .threeMonths: return "90d"
        }
    }
}

