//
//  DateAxisValueFormatter.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 13.06.2025.
//

import Foundation
import Charts
import DGCharts

class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    init(range: TimeRange) {
        switch range {
        case .hour:
            dateFormatter.dateFormat = "HH:mm"
        case .day:
            dateFormatter.dateFormat = "HH:mm"
        case .week, .month:
            dateFormatter.dateFormat = "MMM d"
        case .threeMonths:
            dateFormatter.dateFormat = "MMM"
        }
        dateFormatter.timeZone = .current
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}
