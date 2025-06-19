//
//  DateAxisValueFormatter.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 13.06.2025.
//

import Foundation
import Charts
import DGCharts

class DateAxisValueFormatter: AxisValueFormatter {
    private let dateFormatter: DateFormatter
    
    init(format: String) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value / 1000)
        return dateFormatter.string(from: date)
    }
}
