import UIKit
import Foundation

public protocol MapFactory {
    associatedtype MapView: UIView
    
    var onAnnotationDidTap: ((_ data: Any?)->Void)? { get set }
    
    func setAnnotation(in mapView: MapView, point: MapPoint, image: UIImage?, associatedData: Any?)
    func moveTo(in view: MapView, point: MapPoint, completionHandler: VoidBlock?)
    func showCurrentLocation(in view: MapView)
    func setMapListener(in mapView: MapView)
}
