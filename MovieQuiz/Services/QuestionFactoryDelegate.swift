//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ульта on 12.03.2025.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}

