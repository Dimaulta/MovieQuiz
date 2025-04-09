import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var questionLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
 
    private let presenter = MovieQuizPresenter()
    
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
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.showAlert(model: model)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
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
        
        // Исправлено условие для завершения игры
        if presenter.getCurrentQuestionIndex() < presenter.getTotalQuestionsAmount() - 1 {
            presenter.updateQuestionIndex()
            questionFactory?.requestNextQuestion()
            noButton.isEnabled = true
            yesButton.isEnabled = true
        } else {
            statisticService?.store(correct: correctAnswers, total: presenter.getTotalQuestionsAmount())

            let message = """
                        Ваш результат: \(correctAnswers) из \(presenter.getTotalQuestionsAmount())
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
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.noButton.isEnabled = true
                    self.yesButton.isEnabled = true
                    self.questionFactory?.requestNextQuestion()
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
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
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
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
}
