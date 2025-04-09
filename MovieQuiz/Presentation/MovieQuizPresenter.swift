//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ульта on 09.04.2025.
//


import UIKit

final class MovieQuizPresenter {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func updateQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func getTotalQuestionsAmount() -> Int {
        return questionsAmount
    }

   
    func getCurrentQuestionIndex() -> Int {
        return currentQuestionIndex
    }
}
