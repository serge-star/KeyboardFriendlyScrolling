import UIKit

public class KeyboardFriendlyScrollController {
    private weak var viewController: UIViewController?
    private let scrollView: UIScrollView
    private let defaultContentInsets: UIEdgeInsets
    private let minSpaceToKeyboard: CGFloat

    private var keyboardObservers: [NSObjectProtocol] = []

    public init(viewController: UIViewController, scrollView: UIScrollView, minSpaceToKeyboard: CGFloat = 0, defaultContentInset: UIEdgeInsets? = nil) {
        self.viewController = viewController
        self.scrollView = scrollView

        self.defaultContentInsets = defaultContentInset ?? scrollView.contentInset
        self.minSpaceToKeyboard = minSpaceToKeyboard
    }

    deinit {
        removeObservers()
    }

    public func start() -> KeyboardFriendlyScrollController {
        addObservers()
        return self
    }

    private func addObservers() {
        let keyboardWasShownObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardDidShow, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWasShown(notification)
        }
        let keyboardWillBeHiddenObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillBeHidden(notification)
        }
        keyboardObservers = [keyboardWasShownObserver, keyboardWillBeHiddenObserver]
    }

    private func removeObservers() {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func keyboardWasShown(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let view = viewController?.view
            else { return }

        let scrollViewAbsoluteFrame = view.convert(scrollView.frame, to: nil)
        let overlapHeight = scrollViewAbsoluteFrame.maxY - keyboardFrame.minY + minSpaceToKeyboard
        if overlapHeight > 0 {
            var contentInsets = defaultContentInsets
            contentInsets.bottom += overlapHeight
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    private func keyboardWillBeHidden(_ notification: Notification) {
        scrollView.contentInset = defaultContentInsets
        scrollView.scrollIndicatorInsets = defaultContentInsets
    }
}
