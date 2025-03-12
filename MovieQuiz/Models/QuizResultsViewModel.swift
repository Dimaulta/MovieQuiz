//
//  QuizResultsViewModel.swift
//  MovieQuiz
//
//  Created by Ульта on 08.03.2025.
//

import UIKit

struct QuizResultsViewModel {
    let correctAnswers: Int
    let totalQuestions: Int
    let resultText: String
    
    init(correctAnswers: Int, totalQuestions: Int) {
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.resultText = "Ваш результат: \(correctAnswers) из \(totalQuestions)"
    }
}
