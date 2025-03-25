//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ульта on 12.03.2025.
//

import UIKit

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

