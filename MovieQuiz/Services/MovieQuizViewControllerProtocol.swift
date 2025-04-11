//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ульта on 11.04.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetImageBorder()
    func enableButtons()
    func disableButtons()
    func showAlert(model: AlertModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}
