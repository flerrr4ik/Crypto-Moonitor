//
//  ChartService.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 12.06.2025.
//

import Foundation
import Charts
import DGCharts
import UIKit

final class ChartService {
    static let shared = ChartService()
    private init() {}
    
    // MARK: - Public Methods
    
    func loadAndDisplayChart(
        for id: String,
        in range: TimeRange,
        using chartView: LineChartView,
        cache: [TimeRange: [ChartDataEntry]],
        updateCache: @escaping ([TimeRange: [ChartDataEntry]]) -> Void
    ) {
        if let cached = cache[range] {
            print("📦 Using cached chart data for \(id), range: \(range)")
            updateChart(with: cached, in: range, on: chartView)
            return
        }

        print("🔁 LoadAndDisplayChart triggered for \(id), range: \(range)")

        fetchChartData(id: id, range: range) { entries in
            guard let entries = entries else {
                print("❌ Failed to fetch chart data for \(id), range: \(range)")
                return
            }

            var newCache = cache
            newCache[range] = entries
            updateCache(newCache)

            self.updateChart(with: entries, in: range, on: chartView)
        }
    }
    
    // MARK: - API Methods
    
    func fetchChartData(
        id: String,
        range: TimeRange,
        completion: @escaping ([ChartDataEntry]?) -> Void
    ) {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(id)/market_chart?vs_currency=usd&days=\(range.daysParameter)"
        
        print("🌐 Fetching chart data for \(id), range: \(range) ➜ \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for chart data: \(urlString)")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error for \(id), range: \(range): \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            guard let data = data, !data.isEmpty else {
                print("❌ Empty data for \(id), range: \(range)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(MarketChartResponse.self, from: data)
                let entries = decoded.prices.map { pair in
                    let timestamp = pair[0] / 1000.0
                    let price = pair[1]
                    return ChartDataEntry(x: Double(timestamp), y: price)
                }

                print("📈 Decoded \(entries.count) entries for \(id), range: \(range)")
                DispatchQueue.main.async { completion(entries) }

            } catch {
                print("❌ Decode error for \(id), range: \(range): \(error.localizedDescription)")
                print("🧾 Raw JSON for \(id):\n\(String(data: data, encoding: .utf8) ?? "n/a")")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    // MARK: - Private Methods
    
    private func updateChart(
        with entries: [ChartDataEntry],
        in range: TimeRange,
        on chartView: LineChartView
    ) {
        guard !entries.isEmpty else { return }

        chartView.clear()

        let trimmed = entries.suffix(1000)
        let avg = trimmed.map { $0.y }.reduce(0, +) / Double(trimmed.count)

        let dataSet = LineChartDataSet(entries: Array(trimmed), label: "")
        dataSet.colors = [.systemGreen.withAlphaComponent(0.6)]
        dataSet.lineWidth = 1.5
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.mode = .linear
        dataSet.drawFilledEnabled = true

        let minY = trimmed.map { $0.y }.min() ?? 0
        let maxY = trimmed.map { $0.y }.max() ?? 1
        let ratio = CGFloat((avg - minY) / (maxY - minY))

        let topColor = UIColor.systemRed.cgColor
        let bottomColor = UIColor.systemGreen.cgColor
        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [topColor, bottomColor] as CFArray,
            locations: [0.0, ratio]
        ) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        }

        let data = LineChartData(dataSet: dataSet)
        chartView.data = data

        // Average line
        let avgLine = ChartLimitLine(limit: avg, label: String(format: "Avg: %.2f", avg))
        avgLine.lineWidth = 1
        avgLine.lineDashLengths = [4, 2]
        avgLine.lineColor = .systemGray2
        avgLine.labelPosition = .rightTop
        avgLine.valueFont = .systemFont(ofSize: 10)

        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.addLimitLine(avgLine)
        chartView.leftAxis.axisMinimum = minY * 0.98
        chartView.leftAxis.axisMaximum = maxY * 1.02

        // X Axis format
        switch range {
        case .hour, .day:
            chartView.xAxis.valueFormatter = DateValueFormatter(range: range)
        case .week:
            chartView.xAxis.valueFormatter = DateValueFormatter(range: range)
        case .month, .threeMonths:
            chartView.xAxis.valueFormatter = DateValueFormatter(range: range)
        }

        chartView.xAxis.setLabelCount(6, force: true)
        chartView.notifyDataSetChanged()
    }
}
