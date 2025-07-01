//
//  Ticker.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import Foundation

// MARK: - Ticker Model
struct Ticker: Codable {
    let market: Market
    let base: String
    let target: String
    let last: Double
    let volume: Double?
}

// MARK: - Market Model
struct Market: Codable {
    
    // MARK: - Properties
    let name: String
    let identifier: String
    let hasTradingIncentive: Bool?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case hasTradingIncentive = "has_trading_incentive"
    }
}

// MARK: - Ticker Response Model
struct TickerResponse: Decodable {
    let name: String
    let tickers: [Ticker]
}

// MARK: - Exchange Model
struct Exchange: Decodable {
    
    // MARK: - Properties
    let id: String
    let name: String
    let image: String
    let url: String
}
