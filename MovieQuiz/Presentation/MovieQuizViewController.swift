import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var questionLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
        
        private lazy var presenter = MovieQuizPresenter(viewController: self)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNoButton()
            setupYesButton()
            setupLabels()
            
            alertPresenter = AlertPresenter(viewController: self)
            
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            
            presenter.loadData()
            
            // Проверка состояния кнопок
            print("Yes button enabled: \(yesButton.isEnabled)")
            print("No button enabled: \(noButton.isEnabled)")
            print("Yes button frame: \(yesButton.frame)")
            print("No button frame: \(noButton.frame)")
            
            yesButton.isUserInteractionEnabled = true
            noButton.isUserInteractionEnabled = true
        }
        
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            print("Yes button tapped")
            presenter.yesButtonClicked()
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            print("No button tapped")
            presenter.noButtonClicked()
        }
        
        func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        
        func hideLoadingIndicator() {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        
        func showNetworkError(message: String) {
            hideLoadingIndicator()
            
            let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.presenter.loadData()
            }
            
            alertPresenter?.showAlert(model: model)
        }
        
        func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
        
        func resetImageBorder() {
            imageView.layer.borderWidth = 0
        }
        
        func enableButtons() {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
        
        func disableButtons() {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        }
        
        func showAlert(model: AlertModel) {
            alertPresenter?.showAlert(model: model)
        }
        
        func show(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
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
    }
