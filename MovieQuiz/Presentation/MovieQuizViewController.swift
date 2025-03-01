
import UIKit



final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var questionLabel: UILabel!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        currentQuestionIndex += 1
        
        if currentQuestionIndex < questions.count {
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        } else {
            let alert = UIAlertController(
                title: "Раунд окончен!",
                message: "Ваш результат: \(correctAnswers) из \(questions.count)",
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { _ in
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.noButton.isEnabled = true
                self.yesButton.isEnabled = true
                
                let firstQuestion = self.questions[self.currentQuestionIndex]
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNoButton()
        setupYesButton()
        setupLabels()
        
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: firstQuestion)
        show(quiz: viewModel)
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
    
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        return QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
}
