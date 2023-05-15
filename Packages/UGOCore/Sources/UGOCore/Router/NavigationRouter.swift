import UIKit

public protocol NavigationRouter: Routable { }

public class NavigationRouterImpl: NSObject, NavigationRouter {

  private let rootController: UINavigationController

  public init(rootController: UINavigationController) {
    self.rootController = rootController
    if #available(iOS 13.0, *) {
      let navBarAppearance = UINavigationBarAppearance()
      navBarAppearance.configureWithOpaqueBackground()
      navBarAppearance.shadowColor = .clear
      navBarAppearance.titlePositionAdjustment = .init(horizontal: -200, vertical: -5)
      rootController.navigationBar.standardAppearance = navBarAppearance
      rootController.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    rootController.navigationBar.prefersLargeTitles = true
    rootController.navigationItem.largeTitleDisplayMode = .always
    super.init()
    rootController.delegate = self
  }

  public func toPresent() -> UIViewController? {
    return rootController
  }

  public func present(_ module: Presentable?, animated: Bool) {
    guard let controllerToPresent = module?.toPresent() else { return }
    var presenter: UIViewController = rootController
    while let presented = presenter.presentedViewController {
      presenter = presented
    }
    presenter.present(controllerToPresent, animated: true, completion: nil)
  }

  public func dismissModule(animated: Bool, completion: (() -> Void)?) {
    rootController.dismiss(animated: animated, completion: completion)
  }

  public func push(_ module: Presentable?, animated: Bool) {
    var moduleToPresent = module

    if !rootController.viewControllers.isEmpty {
      moduleToPresent = moduleToPresent?.toPresent()
    }

    guard let controllerToPush = moduleToPresent?.toPresent() else { return }
    controllerToPush.navigationItem.backBarButtonItem = UIBarButtonItem(
      title: " ",
      style: .plain,
      target: nil,
      action: nil
    )
    // Won't show the same screen
    if let topController = rootController.topViewController,
      topController === controllerToPush { return }

    rootController.pushViewController(controllerToPush, animated: animated)
  }

  public func popModule(animated: Bool) {
    rootController.popViewController(animated: animated)
  }

  public func popToRootModule(animated: Bool) {
    rootController.popToRootViewController(animated: animated)
  }

  public func setRootModule(_ module: Presentable?, animated: Bool) {
    guard let controllerToSet = module?.toPresent() else { return }
    rootController.setViewControllers([controllerToSet], animated: animated)
  }

  public func removeModule(_ module: Presentable?) {
    guard let contollerToRemove = module?.toPresent() else { return }
    rootController.viewControllers.removeAll(where: { $0 === contollerToRemove })
  }
}

extension NavigationRouterImpl: UINavigationControllerDelegate {

  public func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
  }
}
