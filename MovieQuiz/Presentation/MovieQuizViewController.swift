
import UIKit

final class MovieQuizViewController: UIViewController,  QuestionFactoryDelegate {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var questionLabel: UILabel!
    
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
                let givenAnswer = false
                showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            }
            
            private func showAnswerResult(isCorrect: Bool) {
                noButton.isEnabled = false
                yesButton.isEnabled = false
                
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 8
                imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
                
                if isCorrect {
                    correctAnswers += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.showNextQuestionOrResults()
                }
            }
            
            private func showNextQuestionOrResults() {
                imageView.layer.borderWidth = 0
                
                if currentQuestionIndex < questionsAmount - 1 {
                    currentQuestionIndex += 1
                    questionFactory.requestNextQuestion()
                    noButton.isEnabled = true
                    yesButton.isEnabled = true
                } else {
                    // Сохраняем результаты текущей игры
                    statisticService?.store(correct: correctAnswers, total: questionsAmount)
                    
                    // Формируем сообщение для алерта
                    let message = """
                    Ваш результат: \(correctAnswers) из \(questionsAmount)
                    Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                    Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                    Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                    """
                    
                    let alertModel = AlertModel(
                        title: "Раунд окончен!",
                        message: message,
                        buttonText: "Сыграть ещё раз",
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.currentQuestionIndex = 0
                            self.correctAnswers = 0
                            self.noButton.isEnabled = true
                            self.yesButton.isEnabled = true
                            self.questionFactory.requestNextQuestion()
                        }
                    )
                    alertPresenter?.showAlert(model: alertModel)
                }
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                setupNoButton()
                setupYesButton()
                setupLabels()
                
                alertPresenter = AlertPresenter(viewController: self)
                statisticService = StatisticService()
                
                imageView.layer.cornerRadius = 20
                imageView.layer.masksToBounds = true
                
                let questionFactory = QuestionFactory()
                questionFactory.setup(delegate: self)
                self.questionFactory = questionFactory
                
                questionFactory.requestNextQuestion()
            }
            
            // MARK: - QuestionFactoryDelegate
            func didReceiveNextQuestion(question: QuizQuestion?) {
                guard let question = question else { return }
                currentQuestion = question
                let viewModel = convert(model: question)
                DispatchQueue.main.async { [weak self] in
                    self?.show(quiz: viewModel)
                }
            }
            
            private func setupLabels() {
                questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
                counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
                textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
                questionLabel.textColor = UIColor(named: "YP White")
                counterLabel.textColor = UIColor(named: "YP White")
                textLabel.textColor = UIColor(named: "YP White")
            }
            
            private func setupNoButton() {
                noButton.setTitle("Нет", for: .normal)
                noButton.backgroundColor = UIColor(named: "YP White")
                noButton.setTitleColor(UIColor(named: "YP Black"), for: .normal)
                noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
                noButton.layer.cornerRadius = 15
            }
            
            private func setupYesButton() {
                yesButton.setTitle("Да", for: .normal)
                yesButton.backgroundColor = UIColor(named: "YP White")
                yesButton.setTitleColor(UIColor(named: "YP Black"), for: .normal)
                yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
                yesButton.layer.cornerRadius = 15
            }
            
            private func convert(model: QuizQuestion) -> QuizStepViewModel {
                return QuizStepViewModel(
                    image: UIImage(named: model.image) ?? UIImage(),
                    question: model.text,
                    questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
                )
            }
            
            private func show(quiz step: QuizStepViewModel) {
                imageView.image = step.image
                textLabel.text = step.question
                counterLabel.text = step.questionNumber
            }
        }
