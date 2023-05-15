extension Routable {

  public func presentWithDimmedBack(_ module: Presentable?) {
    guard let toPresent = module?.toPresent() else {
      return
    }
    let transitioningDelegate = DimmedPopupPresentationManager()
    toPresent.transitioningDelegate = transitioningDelegate
    toPresent.modalPresentationStyle = .custom
    toPresent.transitionManager = transitioningDelegate
    present(toPresent, animated: true)
  }
}

extension Presentable {

  public func presentWithDimmedBack(_ module: Presentable?) {
    guard let presenter = toPresent(), let toPresent = module?.toPresent() else {
      return
    }
    let transitioningDelegate = DimmedPopupPresentationManager()
    toPresent.transitioningDelegate = transitioningDelegate
    toPresent.modalPresentationStyle = .custom
    toPresent.transitionManager = transitioningDelegate
    presenter.present(toPresent, animated: true)
  }
}

import UIKit

extension UIViewController {

  private enum AssociatedKeys {
    static var transitionManager = "transition_manager_key"
  }

  fileprivate var transitionManager: UIViewControllerTransitioningDelegate! {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.transitionManager) as? UIViewControllerTransitioningDelegate
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.transitionManager, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }
}
