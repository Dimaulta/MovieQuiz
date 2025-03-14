//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ульта on 13.03.2025.
//

import UIKit

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }

    func store(correct count: Int, total amount: Int)
}
