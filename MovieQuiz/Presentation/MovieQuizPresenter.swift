//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ульта on 09.04.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestion: QuizQuestion?
   // weak var viewController: MovieQuizViewController?
    weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
  //  init(viewController: MovieQuizViewController) {
        init(viewController: MovieQuizViewControllerProtocol) {
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
    
    private func updateQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func getTotalQuestionsAmount() -> Int {
        return questionsAmount
    }

    private func getCurrentQuestionIndex() -> Int {
        return currentQuestionIndex
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.disableButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) { // Убран private
        guard let question = question else {
            print("No question received")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.enableButtons()
        }
    }
    
    func loadData() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() { // Убран private
        print("Data loaded successfully")
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) { // Убран private
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    private func makeResultsMessage() -> String {
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
    
    private func proceedToNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        viewController.resetImageBorder()

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
            viewController.showAlert(model: alertModel)
        }
    }
}
