import UIKit

class AlertPresenter: AlertPresenterProtocol {
    func showAlert(alertData: AlertModel, viewController: UIViewController) {
        let alert = UIAlertController(title: alertData.title, message: alertData.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertData.buttonText, style: .default, handler: alertData.completion)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
