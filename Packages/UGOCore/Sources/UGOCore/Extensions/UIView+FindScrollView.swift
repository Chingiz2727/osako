import UIKit

extension UIView {

  func findScrollView() -> UIScrollView? {
    if let scrollView = self as? UIScrollView {
      return scrollView
    }

    for view in subviews {
      if let scrollView = view.findScrollView() {
        return scrollView
      }
    }

    return nil
  }
}
