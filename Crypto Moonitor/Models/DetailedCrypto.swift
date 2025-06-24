//
//  DetailedCrypto.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

struct DetailedCrypto: Codable {
    let description: Description?
    let links: Links?
    let marketData: MarketData?
    let categories: [String]?
    let platforms: [String: String]?
    
    struct Description: Codable {
        let en: String
    }
    
    struct Links: Codable {
        let homepage: [String]
        let twitter_screen_name: String?
        let facebook_username: String?
        let subreddit_url: String?
        let chat_url: [String]?
        let official_forum_url: [String]?
        let repos_url: ReposURL
        
        struct ReposURL: Codable {
            let github: [String]
        }
    }
    
    struct MarketData: Codable {
        let totalVolume: [String: Double]?
        let totalSupply: Double?
        let circulatingSupply: Double?
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
    
    enum CodingKeys: String, CodingKey {
        case description
        case links
        case marketData = "market_data"
        case categories
        case platforms
    }
}
