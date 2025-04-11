//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ульта on 09.04.2025.
//

import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
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
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // Убираем активацию кнопок здесь
     //   guard let viewController = viewController else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        viewController.imageView.layer.borderWidth = 0

        // Проверяем, не закончились ли вопросы
        if currentQuestionIndex < questionsAmount - 1 {
            updateQuestionIndex()
            viewController.questionFactory?.requestNextQuestion()
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
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    // Включаем кнопки для следующей игры
                    vc.noButton.isEnabled = true
                    vc.yesButton.isEnabled = true
                    vc.questionFactory?.requestNextQuestion()
                }
            )
            viewController.alertPresenter?.showAlert(model: alertModel)
        }
    }
}
