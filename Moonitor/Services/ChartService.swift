//
//  ChartService.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

import Foundation
import Charts
import DGCharts

final class ChartService {
    
    static let shared = ChartService()
    private init() {}
    
    private var chartCache: [String: [TimeRange: [ChartDataEntry]]] = [:]
    
    
    func fetchChartData(
        cryptoID: String,
        range: TimeRange,
        completion: @escaping ([ChartDataEntry]?) -> Void
    ) {
        if let cached = chartCache[cryptoID]?[range] {
            completion(cached)
            return
        }
        
        let urlString = "https://api.coingecko.com/api/v3/coins/\(cryptoID)/market_chart?vs_currency=usd&days=\(range.rawValue)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard
                let data = data,
                error == nil,
                let chartData = try? JSONDecoder().decode(MarketChartResponse.self, from: data)
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let entries = chartData.prices.map { pair -> ChartDataEntry in
                let timestamp = pair[0] / 1000  // ms to sec
                let price = pair[1]
                return ChartDataEntry(x: Double(timestamp), y: price)
            }
            
            DispatchQueue.main.async {
                if self?.chartCache[cryptoID] == nil {
                    self?.chartCache[cryptoID] = [:]
                }
                self?.chartCache[cryptoID]?[range] = entries
                completion(entries)
            }
        }.resume()
    }
    
}
