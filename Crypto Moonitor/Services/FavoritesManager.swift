//
//  FavoritesManager.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

class FavoritesManager {
    
    // MARK: - Singleton Instance
    
    static let shared = FavoritesManager()
    private init() {}
    
    // MARK: Properties
    
    private let key = "favorites"
    var favoriteIds: Set<String> {
        get {
            return Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }
    
    // MARK: - Public Methods
    
    func addFavorite(id: String) {
        var favorites = favoriteIds
        favorites.insert(id)
        favoriteIds = favorites
    }
    
    func removeFavorite(id: String) {
        var favorites = favoriteIds
        favorites.remove(id)
        favoriteIds = favorites
    }
    
    func isFavorite(id: String) -> Bool {
        return favoriteIds.contains(id)
    }
}
