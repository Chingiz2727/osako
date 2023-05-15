import UIKit

final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let isPresentation: Bool

  init(isPresentation: Bool) {
    self.isPresentation = isPresentation
    super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let animator = self.animator(using: transitionContext)
    animator.startAnimation()
  }

  func interruptibleAnimator(
    using transitionContext: UIViewControllerContextTransitioning
  ) -> UIViewImplicitlyAnimating {
    animator(using: transitionContext)
  }

  private func animator(
    using transitionContext: UIViewControllerContextTransitioning
  ) -> UIViewImplicitlyAnimating {
    let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
    let controller = transitionContext.viewController(forKey: key)!
    let animationDuration = transitionDuration(using: transitionContext)

    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame

    if isPresentation {
      dismissedFrame.origin.y += presentedFrame.height
      transitionContext.containerView.addSubview(controller.view)
    } else {
      dismissedFrame.origin.y += dismissedFrame.height
    }

    let initialFrame = isPresentation ? dismissedFrame : controller.view.frame
    let finalFrame = isPresentation ? presentedFrame : dismissedFrame

    controller.view.frame = initialFrame
    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 0.7) {
      controller.view.frame = finalFrame
    }
    animator.addCompletion { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    return animator
  }
}
