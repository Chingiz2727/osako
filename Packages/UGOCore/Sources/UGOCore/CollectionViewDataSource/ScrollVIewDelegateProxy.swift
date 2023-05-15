import UIKit

class CollectionViewDelegateProxy: ScrollViewDelegateProxy, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    getEachDelegate { delegate in
      delegate.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
  }
  
  private func getEachDelegate(completion: ((UICollectionViewDelegate) -> Void)) {
    let collectionDelegates = delegates.compactMap { $0 as? UICollectionViewDelegate }
    collectionDelegates.forEach {
      completion($0)
    }
  }
}

class ScrollViewDelegateProxy: NSObject, UIScrollViewDelegate {
  
  private(set) var delegates: WeakSet<UIScrollViewDelegate> = WeakSet()
    
  func addDelegate(_ delegate: UIScrollViewDelegate) {
    delegates.add(delegate)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView)  {
    delegates.forEach { delegate in
      delegate.scrollViewDidScroll?(scrollView)
    }
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewDidZoom?(scrollView)
    }
  }

    
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewWillBeginDragging?(scrollView)
    }
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    delegates.forEach { delegate in
      delegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    delegates.forEach { delegate in
      delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
  }

    
    
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewWillBeginDecelerating?(scrollView)
    }
  }

    
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewDidEndDecelerating?(scrollView)
    }
  }
    
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewDidEndScrollingAnimation?(scrollView)
    }
  }
    
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return delegates.compactMap { $0.viewForZooming?(in: scrollView) }.first
  }

    
  func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    delegates.forEach { delegate in
      delegate.scrollViewWillBeginZooming?(scrollView, with: view)
    }
  }

    
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    delegates.forEach { delegate in
      delegate.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
  }

  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    return delegates.compactMap { $0.scrollViewShouldScrollToTop?(scrollView) }.first ?? true
  }

    
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
      delegate.scrollViewDidScrollToTop?(scrollView)
    }
  }

    
  func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    delegates.forEach { delegate in
        if #available(iOS 11.0, *) {
            delegate.scrollViewDidChangeAdjustedContentInset?(scrollView)
        } else {
            // Fallback on earlier versions
        }
    }
  }
}
