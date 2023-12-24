import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var presenter: MovieQuizPresenter?
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var launchScreen: UIImageView!

    @IBAction private func answerButtonClicked(_ sender: UIButton) {
        presenter?.answerButtonClicked(sender, yesButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func showNextQuestion(_ viewModel: QuizStepViewModel) {
        showQuestion(quiz: viewModel)
        hideLaunchScreen()
        hideLoadingIndicator()
    }

    func showAnswer(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showLaunchScreen() {
        launchScreen.isHidden = false
    }
    
    func hideLaunchScreen() {
        launchScreen.isHidden = true
    }
    
    func showAlert(_ alertData: AlertModel) {
        let alert = UIAlertController(title: alertData.title, message: alertData.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertData.buttonText, style: .default, handler: alertData.completion)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
