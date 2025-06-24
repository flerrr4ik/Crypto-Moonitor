//
//  APIService.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit
import DGCharts

class APIService {
    static let shared = APIService()
    
    func fetchCryptos(completion: @escaping ([Crypto]?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for fetchCryptos")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error in fetchCryptos:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data in fetchCryptos")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Crypto].self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("❌ Decoding error in fetchCryptos:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response: \(raw)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func fetchTickers(for id: String, completion: @escaping ([Ticker]?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(id)/tickers"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for fetchTickers")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error in fetchTickers:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received in fetchTickers")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(TickerResponse.self, from: data)
                let limitedTickers = Array(result.tickers.prefix(30))
                completion(limitedTickers)
            } catch {
                print("❌ Decode error in fetchTickers:", error)
                print(String(data: data, encoding: .utf8) ?? "n/a")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchExchanges(completion: @escaping ([Exchange]?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/exchanges?per_page=30&page=1"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Network error:", error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            do {
                let exchanges  = try JSONDecoder().decode([Exchange].self, from: data)
                DispatchQueue.main.async {
                    completion(exchanges)
                }
            } catch {
                print("Decoding error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func fetchDetail(for id: String, completion: @escaping (DetailedCrypto?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=false&community_data=false&developer_data=false"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let detailedCrypto = try JSONDecoder().decode(DetailedCrypto.self, from: data)
                completion(detailedCrypto)
            } catch {
                print("❌ Decode error: \(error.localizedDescription)")
                print("🧾 Raw JSON:", String(data: data, encoding: .utf8) ?? "n/a")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchCryptoByID(id: String, completion: @escaping (Crypto?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(id)&sparkline=true"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Network error:", error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            do {
                let result = try JSONDecoder().decode([Crypto].self, from: data)
                DispatchQueue.main.async {
                    completion(result.first)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
