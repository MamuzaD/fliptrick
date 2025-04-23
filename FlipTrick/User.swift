//
//  User.swift
//  FlipTrick
//
//  Created by Daniel Mamuza on 4/23/25.
//


import Foundation

struct SavedGame: Codable {
    let score: Int
    let date: Date
}

class GameManager {
    static let shared = GameManager()
    private let savedGamesKey = "SavedGames"

    private init() {}

    func saveGame(score: Int) {
        var savedGames = loadSavedGames()
        let savedGame = SavedGame(score: score, date: Date())
        savedGames.insert(savedGame, at: 0)
        if let data = try? JSONEncoder().encode(savedGames) {
            UserDefaults.standard.set(data, forKey: savedGamesKey)
        }
        print("Game saved! Score: \(score), Date: \(savedGame.date)")
    }

    func loadSavedGames() -> [SavedGame] {
        if let data = UserDefaults.standard.data(forKey: savedGamesKey),
           let games = try? JSONDecoder().decode([SavedGame].self, from: data) {
            return games
        }
        return []
    }
}
