public protocol Coordinator: AnyObject {

  var router: Routable { get }

  func start()
  func handle(deepLink: DeepLink?)
}

public protocol DeepLink {}
