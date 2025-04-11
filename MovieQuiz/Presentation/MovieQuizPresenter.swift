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
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
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
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            // Включаем кнопки после получения нового вопроса
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
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        viewController.imageView.layer.borderWidth = 0

        // Проверяем, не закончились ли вопросы
        if currentQuestionIndex < questionsAmount - 1 {
            updateQuestionIndex()
            questionFactory?.requestNextQuestion()
        } else {
            viewController.statisticService?.store(correct: correctAnswers, total: questionsAmount)

            let message = """
            Ваш результат: \(correctAnswers) из \(questionsAmount)
            Количество сыгранных квизов: \(viewController.statisticService?.gamesCount ?? 0)
            Рекорд: \(viewController.statisticService?.bestGame.correct ?? 0)/\(viewController.statisticService?.bestGame.total ?? 0) (\(viewController.statisticService?.bestGame.date.dateTimeString ?? ""))
            Средняя точность: \(String(format: "%.2f", viewController.statisticService?.totalAccuracy ?? 0))%
            """

            let alertModel = AlertModel(
                title: "Раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self,
                          let vc = self.viewController else { return }
                    self.restartGame()
                    // Включаем кнопки для следующей игры
                    vc.noButton.isEnabled = true
                    vc.yesButton.isEnabled = true
                    self.questionFactory?.requestNextQuestion()
                }
            )
            viewController.alertPresenter?.showAlert(model: alertModel)
        }
    }
}
