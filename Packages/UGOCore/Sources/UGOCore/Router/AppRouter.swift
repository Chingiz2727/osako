import UIKit

public protocol AppRouter: Routable {

  func setRootModule(_ module: Presentable?, animation: AppRouterAnimation)
}

public final class AppRouterImpl: NSObject, AppRouter {

  private weak var window: UIWindow?

  private var rootController: UIViewController? {
    get {
      return window?.rootViewController
    } set {
      rootController?.dismiss(animated: false, completion: nil)
      window?.subviews.forEach { $0.removeFromSuperview() }
      window?.rootViewController = newValue
    }
  }

  public init(window: UIWindow?) {
    self.window = window
  }

  public func toPresent() -> UIViewController? {
    return rootController
  }

  public func setRootModule(_ module: Presentable?, animated: Bool) {
    let animation: AppRouterAnimation = animated ? .scaledFade : .none
    setRootModule(module, animation: animation)
  }

  public func present(_ module: Presentable?, animated: Bool) {
    guard let controllerToPresent = module?.toPresent() else { return }
    guard var presenter = rootController else { return }
    while let presented = presenter.presentedViewController {
      presenter = presented
    }
    presenter.present(controllerToPresent, animated: true, completion: nil)
  }

  public func dismissModule(animated: Bool, completion: (() -> Void)?) {
    rootController?.dismiss(animated: animated, completion: completion)
  }

  public func push(_ module: Presentable?, animated: Bool) {
    guard let root = rootController as? UINavigationController else { return }

    var customizableModule = module

    if !root.viewControllers.isEmpty {
      customizableModule = customizableModule?.toPresent()
    }

    guard let controllerToPush = customizableModule?.toPresent() else { return }
    (rootController as? UINavigationController)?.pushViewController(controllerToPush, animated: animated)
  }

  public func popModule(animated: Bool) {
    (rootController as? UINavigationController)?.popViewController(animated: animated)
  }

  public func popToRootModule(animated: Bool) {
    (rootController as? UINavigationController)?.popToRootViewController(animated: animated)
  }

  public func removeModule(_ module: Presentable?) {
    fatalError("Should be configured")
  }

  // MARK: AppRouter

  public func setRootModule(_ module: Presentable?, animation: AppRouterAnimation) {
    guard let toController = module?.toPresent() else { return }

    let fromController = rootController
    let fromSnapshot = fromController?.view.snapshotView(afterScreenUpdates: true)
    rootController = toController

    guard animation.animated, let snapshot = fromSnapshot else { return }

    toController.view.addSubview(snapshot)
    var animationBlock: (() -> Void)!
    switch animation {
    case .scaledFade:
      animationBlock = {
        snapshot.alpha = 0.0
        snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
      }
    case .left:
      animationBlock = {
        snapshot.frame = CGRect(
          origin: CGPoint(x: -snapshot.frame.width, y: 0),
          size: snapshot.frame.size
        )
      }
    case .right:
      animationBlock = {
        snapshot.frame = CGRect(
          origin: CGPoint(x: snapshot.frame.width, y: 0),
          size: snapshot.frame.size
        )
      }
    case .bottom:
      animationBlock = {
        snapshot.frame = CGRect(
          origin: CGPoint(x: 0, y: snapshot.frame.height),
          size: snapshot.frame.size
        )
      }
    case .top:
      animationBlock = {
        snapshot.frame = CGRect(
          origin: CGPoint(x: 0, y: -snapshot.frame.height),
          size: snapshot.frame.size
        )
      }
    case .none:
      fatalError("Can't be used in animation block")
    }
    UIView.animate(
      withDuration: Constants.animationDuration,
      animations: animationBlock,
      completion: { _ in
        snapshot.removeFromSuperview()
      }
    )
  }
}

public enum AppRouterAnimation {

  case none
  case scaledFade
  case left
  case right
  case bottom
  case top

  var animated: Bool {
    return self != .none
  }
}

private extension AppRouterImpl {

  enum Constants {

    static var animationDuration: TimeInterval = 0.3
  }
}
