import Foundation
import UIKit

open class MapManager<T: MapFactory> {
    
    private var engine: T
    
    public init(engine: T) {
        self.engine = engine
    }
    public var onAnnotationDidTap: ((_ data: Any?)->Void)? {
        didSet {
            engine.onAnnotationDidTap = onAnnotationDidTap
        }
    }

    public func showCurrentLocation(in view: T.MapView) {
        engine.showCurrentLocation(in: view)
    }
    
    public func createAnnotation(in view: T.MapView, point: MapPoint, image: UIImage?, associatedData: Any?) {
        engine.setAnnotation(in: view, point: point, image: image, associatedData: associatedData)
    }
    
    public func moveTo(in view: T.MapView, point: MapPoint, completionHandler: VoidBlock?) {
        engine.moveTo(in: view, point: point, completionHandler: completionHandler)
    }

    public func setMapListener(in view: T.MapView) {
        engine.setMapListener(in: view)
    }
    
    
}
