import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showAnswer(isCorrect: Bool) {
        print("showAnswer")
    }
    
    func showQuestion(quiz step: MovieQuiz.QuizStepViewModel) {
        print("showQuestion")
    }
    
    func showNextQuestion(_ viewModel: MovieQuiz.QuizStepViewModel) {
        print("showNextQuestion")
    }
    
    func showLoadingIndicator() {
        print("showLoadingIndicator")
    }
    
    func hideLoadingIndicator() {
        print("hideLoadingIndicator")
    }
    
    func showLaunchScreen() {
        print("showLaunchScreen")
    }
    
    func hideLaunchScreen() {
        print("hideLaunchScreen")
    }
    
    func showAlert(_ alertData: MovieQuiz.AlertModel) {
        print("showAlert")
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
