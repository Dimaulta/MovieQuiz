//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ульта on 13.03.2025.
//

import UIKit

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case totalCorrect
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
  
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
  
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        return totalQuestions == 0 ? 0.0 : (Double(totalCorrect) / Double(totalQuestions)) * 100
    }
    
   
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
  
    func store(correct count: Int, total amount: Int) {
        
        let currentTotalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let currentTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentTotalCorrect + count, forKey: Keys.totalCorrect.rawValue)
        storage.set(currentTotalQuestions + amount, forKey: Keys.totalQuestions.rawValue)
        
        
        gamesCount += 1
        
       
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}

extension StatisticService: StatisticServiceProtocol {
 
}
