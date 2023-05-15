import UIKit

class TransitionDriver: UIPercentDrivenInteractiveTransition {

  var scrollView: UIScrollView?

  func link(to controller: UIViewController) {
    presentedController = controller

    panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(recognizer:)))
    presentedController?.view.addGestureRecognizer(panRecognizer!)
    findScrollView(in: controller)
  }

  private func findScrollView(in controller: UIViewController) {
    self.scrollView = controller.view.findScrollView()
    scrollView?.bounces = false
  }

  private weak var presentedController: UIViewController?
  private var panRecognizer: UIPanGestureRecognizer?

  override var wantsInteractiveStart: Bool {
    get {
      let gestureIsActive = panRecognizer?.state == .began
      return gestureIsActive
    }
    // swiftlint:disable all
    set {}
  }
}

extension TransitionDriver {

  @objc private func handleDismiss(recognizer r: UIPanGestureRecognizer) {
    switch r.state {
    case .began:
      pause() // Pause allows to detect isRunning

      if !isRunning {
        presentedController?.dismiss(animated: true) // Start the new one
      }

    case .changed:
      update(percentComplete + r.incrementToBottom(maxTranslation: maxTranslation))

    case .ended, .cancelled:
      if r.isProjectedToDownHalf(maxTranslation: maxTranslation) {
        finish()
      } else {
        cancel()
      }

    case .failed:
      cancel()

    default:
      break
    }
  }

  var maxTranslation: CGFloat {
    return presentedController?.view.frame.height ?? 0
  }

  /// `pause()` before call `isRunning`
  private var isRunning: Bool {
    return percentComplete != 0
  }
}

private extension UIPanGestureRecognizer {
  func isProjectedToDownHalf(maxTranslation: CGFloat) -> Bool {
    let endLocation = projectedLocation(decelerationRate: .fast)
    let isPresentationCompleted = endLocation.y > maxTranslation / 2

    return isPresentationCompleted
  }

  func incrementToBottom(maxTranslation: CGFloat) -> CGFloat {
    let translation = self.translation(in: view).y
    setTranslation(.zero, in: nil)

    let percentIncrement = translation / maxTranslation
    return percentIncrement
  }
}
