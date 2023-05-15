import UIKit

/// Encapsulates feed section's logic layer.
///
/// The logic behind this is that we have each section isolated with it's own api request
/// and option to perform a paginated query.
///
public protocol FeedSectionViewModel: AnyObject, CustomReflectable, CustomStringConvertible {
    
    /// The current state of a section
    var state: FeedState { get }
    
    var isVisible: Bool { get }
    
    /// Provides up-to-date feed state to a listener
    var onUpdate: ((FeedState.Update) -> ())? { get set }
    
    /// A bulder of a Section Controller
    var sectionBuilder: SectionControllerBuilder! { get }
    
    /// Associated with the view model section controller if it was created
    var sectionController: ListSectionController? { get }
    
    /// In most cases implementation of this method should take `sectionBuilder`,
    /// create a section controller and store it in `sectionController` field
    func buildSectionController() -> ListSectionController
    
    /// Accessors to api
    func reloadData(cachePolicy: APICachePolicy)
    func loadNext()
}

extension FeedSectionViewModel {
    public var description: String {
        return "\(self), state: \(state.description), isVisible: \(isVisible)"
    }
    
    public var customMirror: Mirror {
        return Mirror(self, children: ["state": state, "isVisible": isVisible], displayStyle: .struct, ancestorRepresentation: .generated)
    }
}

open class BaseFeedSectionViewModel: NSObject, FeedSectionViewModel {
    
    public var sectionBuilder: SectionControllerBuilder!
    public var state = FeedState(items: [], loadingState: .notReady)
    public var isVisible: Bool { return true }
    public var onUpdate: ((FeedState.Update) -> ())?
    
    public var sectionController: ListSectionController?
    
    public init(sectionControllerBuilder: SectionControllerBuilder?) {
        self.sectionBuilder = sectionControllerBuilder
        super.init()
    }
    
    open func reloadData(cachePolicy: APICachePolicy) {
        
    }
    
    open func loadNext() {
        
    }
    
    public func buildSectionController() -> ListSectionController {
        let sectionController = sectionBuilder.build(state: state)
        self.sectionController = sectionController // Cache
        return sectionController
    }
    
    public override var description: String {
        return "\(type(of: self)), state: \(state.description), isVisible: \(isVisible)"
    }
}

extension BaseFeedSectionViewModel: CustomLeafReflectable {
    public var customMirror: Mirror {
        
        return Mirror(self, children: ["state": state, "isVisible": isVisible], displayStyle: .struct, ancestorRepresentation: .generated)
    }
}
