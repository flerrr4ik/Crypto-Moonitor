//
//  TickerCache.swift
//  Moonitor
//
//  Created by Andrii Pyrskyi on 19.06.2025.
//

import Foundation

final class MarketDataCache {
    
    static let shared = MarketDataCache()
    
    private var tickerCache: [String: [Ticker]] = [:]         // [cryptoID: [Ticker]]
    private var exchanges: [Exchange]? = nil                  // Список бірж
    var exchangeLogos: [String: String] = [:]         // [exchangeName: logoURL]
    var exchangeURLs: [String: String] = [:]          // [exchangeName: siteURL]
    
    private init() {}
    
    // MARK: - Tickers
    
    func getTickers(for cryptoID: String) -> [Ticker]? {
        return tickerCache[cryptoID]
    }
    
    func setTickers(_ tickers: [Ticker], for cryptoID: String) {
        tickerCache[cryptoID] = tickers
    }
    
    func hasTickers(for cryptoID: String) -> Bool {
        return tickerCache[cryptoID] != nil
    }
    
    // MARK: - Exchanges
    
    func setExchanges(_ newExchanges: [Exchange]) {
        self.exchanges = newExchanges
        self.exchangeLogos = Dictionary(uniqueKeysWithValues: newExchanges.map { ($0.name, $0.image) })
        self.exchangeURLs = Dictionary(uniqueKeysWithValues: newExchanges.map { ($0.name, $0.url) })
    }
    
    func getExchanges() -> [Exchange]? {
        return exchanges
    }
    
    func hasExchanges() -> Bool {
        return exchanges != nil
    }
    
    func logo(for exchangeName: String) -> String? {
        return exchangeLogos[exchangeName]
    }
    
    func url(for exchangeName: String) -> String? {
        return exchangeURLs[exchangeName]
    }
    
    var exchangeLogosDict: [String: String] {
        return exchangeLogos
    }
    
    var exchangeURLsDict: [String: String] {
        return exchangeURLs
    }
    
    func clearAll() {
        tickerCache.removeAll()
        exchanges = nil
        exchangeLogos.removeAll()
        exchangeURLs.removeAll()
    }
}
