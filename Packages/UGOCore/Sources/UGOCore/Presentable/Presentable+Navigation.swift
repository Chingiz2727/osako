import UIKit

public enum DismissItemStyle {

  case cancel
  case done
}

public extension Presentable {

  func embededInNavigation() -> Presentable? {
    guard let controllerToPresent = toPresent() else { return nil }
    let navController = UINavigationController(rootViewController: controllerToPresent)
    return navController
  }


  func withRemovedBackItem() -> Presentable? {
    guard let controllerToPresent = toPresent() else { return nil }
    controllerToPresent.navigationItem.hidesBackButton = true
    return controllerToPresent
  }

  func withDismissItem(style: DismissItemStyle = .cancel) -> Presentable? {
    guard let controllerToPresent = toPresent() else { return nil }
    let button = UIBarButtonItem(
      barButtonSystemItem: {
        switch style {
        case .cancel:
          return .cancel
        case .done:
          return .done
        }
    }(),
      target: controllerToPresent,
      action: #selector(UIViewController.dismissModal)
    )
    let identifier = style == .cancel ? AccessibilityIdentifiers.cancelButton : AccessibilityIdentifiers.doneButton
    button.accessibilityIdentifier = identifier
    controllerToPresent.navigationItem.rightBarButtonItem = button

    return controllerToPresent
  }

  func withDisabledLargeTitle() -> Presentable? {
    guard let controllerToPresent = toPresent() else { return nil }
    controllerToPresent.navigationItem.largeTitleDisplayMode = .never
    return controllerToPresent
  }

  func withHiddenBottomBar() -> Presentable? {
    toPresent()?.hidesBottomBarWhenPushed = true
    return self
  }
}

private enum AccessibilityIdentifiers {

  static let cancelButton = "navigation_bar_cancel_button"
  static let doneButton = "navigation_bar_cancel_button"
}

public extension UIViewController {

  @objc func dismissModal() {
    dismiss(animated: true, completion: nil)
  }
}
