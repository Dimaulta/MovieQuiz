//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ульта on 09.04.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func getTotalQuestionsAmount() -> Int {
        return questionsAmount
    }

    func getCurrentQuestionIndex() -> Int {
        return currentQuestionIndex
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            print("No question received")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.yesButton.isEnabled = true
            self?.viewController?.noButton.isEnabled = true
        }
    }
    
    func loadData() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        print("Data loaded successfully")
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        viewController.imageView.layer.borderWidth = 0

        if currentQuestionIndex < questionsAmount - 1 {
            updateQuestionIndex()
            questionFactory?.requestNextQuestion()
        } else {
            let message = makeResultsMessage()
            
            let alertModel = AlertModel(
                title: "Раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                    self.questionFactory?.requestNextQuestion()
                }
            )
            viewController.alertPresenter?.showAlert(model: alertModel)
        }
    }
}
