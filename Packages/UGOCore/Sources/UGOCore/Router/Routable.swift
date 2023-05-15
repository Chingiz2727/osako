public protocol Routable: Presentable, AnyObject {

  func present(_ module: Presentable?, animated: Bool)
  func present(_ module: Presentable?, style: PresentationStyle, animated: Bool)
  func presentWithDimmedBack(_ module: Presentable?)

  func push(_ module: Presentable?)
  func push(_ module: Presentable?, animated: Bool)

  func popModule()
  func popModule(animated: Bool)

  func popToRootModule()
  func popToRootModule(animated: Bool)

  func dismissModule()
  func dismissModule(animated: Bool, completion: (() -> Void)?)

  func setRootModule(_ module: Presentable?)
  func setRootModule(_ module: Presentable?, animated: Bool)

  func removeModule(_ module: Presentable?)
}

public extension Routable {

  func present(_ module: Presentable?, style: PresentationStyle = .fullScreen, animated: Bool = true) {
    present(module?.withPresentation(style: style), animated: true)
  }

  func push(_ module: Presentable?) {
    push(module, animated: true)
  }

  func popModule() {
    popModule(animated: true)
  }

  func popToRootModule() {
    popToRootModule(animated: true)
  }

  func dismissModule() {
    dismissModule(animated: true, completion: nil)
  }

  func setRootModule(_ module: Presentable?) {
    setRootModule(module, animated: true)
  }
}

private extension Presentable {

  func withPresentation(style: PresentationStyle) -> Presentable? {
    guard let controllerToPresent = toPresent() else { return nil }

    switch style {
    case .fullScreen:
      controllerToPresent.modalPresentationStyle = .fullScreen
    case .pageSheet:
      controllerToPresent.modalPresentationStyle = .pageSheet
    case .overCurrentContext:
      controllerToPresent.modalPresentationStyle = .overCurrentContext
    case .custom:
      controllerToPresent.modalPresentationStyle = .custom
    }

    return controllerToPresent
  }
}

public enum PresentationStyle {
  case fullScreen
  case pageSheet
  case overCurrentContext
  case custom
}
