//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Ульта on 10.03.2025.
//

import UIKit

//protocol QuestionFactoryProtocol {
//    func requestNextQuestion() -> QuizQuestion?
//}


protocol QuestionFactoryProtocol {
  //  var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
}

