import UIKit

final class MovieQuizPresenter {
    weak var viewController: MovieQuizViewController?

    let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    func answerButtonClicked(_ sender: UIButton, _ yesButton: UIButton) {
        let isYesClicked = sender == yesButton
        let isCorrect = currentQuestion?.correctAnswer == isYesClicked
        viewController?.showAnswer(isCorrect: isCorrect)
        correctAnswers = correctAnswers + (isCorrect ? 1 : 0)
        viewController?.showNextQuestionOrResults()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
