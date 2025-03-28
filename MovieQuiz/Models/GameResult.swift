//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ульта on 13.03.2025.
//
import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
