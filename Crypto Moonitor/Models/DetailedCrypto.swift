//
//  DetailedCrypto.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import Foundation

struct DetailedCrypto: Codable {
    
    // MARK: - Main Properties
    
    let description: Description?
    let links: Links?
    let marketData: MarketData?
    let categories: [String]?
    let platforms: [String: String]?
    
    // MARK: - Nested Types
    
    struct Description: Codable {
        let en: String
    }
    
    struct Links: Codable {
        
        // MARK: - Social Media Links
        let homepage: [String]
        let twitter_screen_name: String?
        let facebook_username: String?
        let subreddit_url: String?
        
        // MARK: - Code Repositories
        let repos_url: ReposURL
        
        struct ReposURL: Codable {
            let github: [String]
        }
    }
    
    struct MarketData: Codable {
        
        // MARK: - Supply Data
        let totalVolume: [String: Double]?
        let totalSupply: Double?
        let circulatingSupply: Double?
        
        // MARK: - Price Extremes
        let ath: [String: Double]?
        let atl: [String: Double]?
        
        enum CodingKeys: String, CodingKey {
            case totalVolume = "total_volume"
            case totalSupply = "total_supply"
            case circulatingSupply = "circulating_supply"
            case ath
            case atl
        }
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case description
        case links
        case marketData = "market_data"
        case categories
        case platforms
    }
}
