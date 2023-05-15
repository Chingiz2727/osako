import UIKit

class DimmedPopupPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

  let driver = TransitionDriver()

  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    driver.link(to: presented)
    let presentationController = DimmedPopupPresentationController(
      presentedViewController: presented,
      presenting: presenting ?? source
    )
    presentationController.driver = driver
    return presentationController
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SlideInPresentationAnimator(isPresentation: true)
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    SlideInPresentationAnimator(isPresentation: false)
  }

  func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    return driver
  }
}
