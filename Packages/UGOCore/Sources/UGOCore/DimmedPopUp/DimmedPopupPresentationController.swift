import UIKit
import SnapKit

final class DimmedPopupPresentationController: UIPresentationController {

  var driver: TransitionDriver?

  override var shouldPresentInFullscreen: Bool {
    return false
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    guard
      let containerView = containerView,
      let presentedView = presentedView
      else {
        return .zero
    }

    let targetWidth = containerView.bounds.width
    let fittingSize = CGSize(
      width: targetWidth,
      height: UIView.layoutFittingCompressedSize.height
    )

    let maxHeight = containerView.bounds.height - max(containerView.safeAreaInsets.top, 20) - 20

    var targetHeight = presentedView.systemLayoutSizeFitting(
      fittingSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .defaultLow
    ).height

    targetHeight = min(targetHeight, maxHeight)

    var frame = containerView.bounds
    frame.origin.y += frame.size.height - targetHeight
    frame.size.width = targetWidth
    frame.size.height = targetHeight
    return frame
  }

  private var dimmingView = UIView()

  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setupDimmingView()
  }

  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()

    containerView?.insertSubview(dimmingView, at: 0)
    presentedView.map { containerView?.addSubview($0) }
    dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }

    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }

  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }

    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }

  override func presentationTransitionDidEnd(_ completed: Bool) {
    super.presentationTransitionDidEnd(completed)
    if !completed {
      dimmingView.removeFromSuperview()
    }
  }

  override func dismissalTransitionDidEnd(_ completed: Bool) {
    super.dismissalTransitionDidEnd(completed)
    if completed {
      dimmingView.removeFromSuperview()
    }
  }

  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
  }

  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
  }

  override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
    super.preferredContentSizeDidChange(forChildContentContainer: container)
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
}

private extension DimmedPopupPresentationController {

  private func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
    dimmingView.alpha = 0.0

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
    dimmingView.addGestureRecognizer(tapGesture)
    dimmingView.isUserInteractionEnabled = true
  }

  @objc func dimmingViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    if let vc = presentedViewController as? DimmingViewTappedProtocol {
      vc.dimmingViewTapped()
    } else {
      presentedViewController.dismiss(animated: true)
    }
  }
}

protocol DimmingViewTappedProtocol: AnyObject {
  func dimmingViewTapped()
}

extension DimmingViewTappedProtocol where Self: UIViewController {
  func dimmingViewTapped() {
    dismiss(animated: true, completion: nil)
  }
}
