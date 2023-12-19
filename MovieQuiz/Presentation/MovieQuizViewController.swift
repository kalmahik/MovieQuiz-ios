import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let presenter = MovieQuizPresenter()
    private lazy var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()
    private lazy var moviesLoader: MoviesLoader = MoviesLoader()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var launchScreen: UIImageView!

    @IBAction private func answerButtonClicked(_ sender: UIButton) {
        presenter.answerButtonClicked(sender, yesButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        loadMovies(UIAlertAction())
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.showQuestion(quiz: viewModel)
            self.hideLaunchScreen()
            self.hideLoadingIndicator()
        }
    }
    
    func didLoadData() {
        loadQuestion(UIAlertAction())
    }
    
    func didFailNextQuestion(with error: Error) {
        showNetworkErrorModal(message: error.localizedDescription, handler: loadQuestion)
    }
    
    func didFailData(with error: Error) {
        showNetworkErrorModal(message: error.localizedDescription, handler: loadMovies)
    }
    
    func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            showFinishGameModal()
        } else {
            presenter.switchToNextQuestion()
            loadQuestion(UIAlertAction())
        }
    }
    
    private func showNetworkErrorModal(message: String, handler: @escaping (UIAlertAction) -> Void) {
        let alertData = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: handler
        )
        alertPresenter.showAlert(alertData: alertData, viewController: self)
    }
    
    private func showFinishGameModal() {
        showLaunchScreen()
        let alertData = AlertModel(
            title: "Этот раунд окончен!",
            message: generateFinisMessage(),
            buttonText: "Сыграть ещё раз",
            completion: resetGame
        )
        alertPresenter.showAlert(alertData: alertData, viewController: self)
    }
    
    func showAnswer(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
    }
    
    private func resetGame(_: UIAlertAction) {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        loadQuestion(UIAlertAction())
    }
    
    private func loadMovies(_: UIAlertAction) {
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func loadQuestion(_: UIAlertAction) {
        showLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showLaunchScreen() {
        launchScreen.isHidden = false
    }
    
    private func hideLaunchScreen() {
        launchScreen.isHidden = true
    }

    private func generateFinisMessage() -> String {
        let bestGame = statisticService.bestGame
        let message =
        "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n" +
        "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
        "Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\n" +
        "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        return message
    }
}
