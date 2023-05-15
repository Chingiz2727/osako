import UIKit

open class BaseCoordinator: Coordinator {

  public private(set) var childCoordinators: [Coordinator] = []

  public let router: Routable

  public init(router: Routable) {
    self.router = router
  }

  open func start() {
    fatalError("Implement 'start' method in \(self.self)")
  }

  open func handle(deepLink: DeepLink?) {}

  public func addDependency(_ coordinator: Coordinator) {
    if childCoordinators.contains(where: { $0 === coordinator }) {
      return
    }

    childCoordinators.append(coordinator)
  }

  public func removeDependency(_ coordinator: Coordinator?) {
    childCoordinators.removeAll(where: { $0 === coordinator })
  }

  public func removeAllDependencies() {
    childCoordinators.removeAll()
  }
}

// MARK: Recursive searching all childCoordinators

public extension BaseCoordinator {

  func getAllChildCoordinators(includeSelf: Bool = false) -> [BaseCoordinator] {
    if includeSelf {
      return [self] + allChildCoordinators
    } else {
      return allChildCoordinators
    }
  }

  private var allChildCoordinators: [BaseCoordinator] {
    let childs = childCoordinators
      .compactMap { $0 as? BaseCoordinator }

    let subChilds = childs
      .flatMap { $0.allChildCoordinators }

    return childs + subChilds
  }
}

// MARK: Support

public extension BaseCoordinator {

  var lastPresentedViewController: UIViewController? {
    var viewController = router.toPresent()?.presentedViewController
    while let presented = viewController?.presentedViewController {
      viewController = presented
    }
    return viewController
  }
}
