import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol

    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        loadMovies(UIAlertAction())
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let questionModel = convert(model: question)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.showNextQuestion(questionModel)
        }
    }
    
    func didLoadData() {
        loadQuestion(UIAlertAction())
    }
    
    func didFailNextQuestion(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkErrorModal(message: error.localizedDescription, handler: self?.loadQuestion)
        }
    }
    
    func didFailData(with error: Error) {
        showNetworkErrorModal(message: error.localizedDescription, handler: loadMovies)
    }
    
    func answerButtonClicked(_ sender: UIButton, _ yesButton: UIButton) {
        let isYesClicked = sender == yesButton
        let isCorrect = currentQuestion?.correctAnswer == isYesClicked
        viewController?.showAnswer(isCorrect: isCorrect)
        correctAnswers = correctAnswers + (isCorrect ? 1 : 0)
        showNextQuestionOrResults()
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            showFinishGameModal()
        } else {
            switchToNextQuestion()
            loadQuestion(UIAlertAction())
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func resetGame(_: UIAlertAction) {
        currentQuestionIndex = 0
        correctAnswers = 0
        loadQuestion(UIAlertAction())
    }
    
    private func loadMovies(_: UIAlertAction) {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func loadQuestion(_: UIAlertAction) -> Void {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func showNetworkErrorModal(message: String, handler: ((UIAlertAction) -> Void)?) {
        let alertData = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: handler
        )
        viewController?.showAlert(alertData)
    }
    
    private func showFinishGameModal() {
        viewController?.showLaunchScreen()
        let alertData = AlertModel(
            title: "Этот раунд окончен!",
            message: generateFinisMessage(),
            buttonText: "Сыграть ещё раз",
            completion: resetGame
        )
        viewController?.showAlert(alertData)
    }
    
    private func generateFinisMessage() -> String {
        let bestGame = statisticService.bestGame
        let message =
        "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
        "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
        "Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\n" +
        "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        return message
    }
}
