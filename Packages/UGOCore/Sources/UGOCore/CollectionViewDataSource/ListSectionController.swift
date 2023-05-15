import UIKit

/// Encapsulates single collection view section logic
///
/// The section contains
/// 1. reference to the collection context: `ListCollectionContainer` which, in turn,
///    encapsulates collection view, view controller, section information and methods to reload
///    the section cells
/// 2. items info such as array of items and amount of them which used by data source
/// 3. collection view correspoding methods to get the cells `cellForItem` and handle cell
///    selection `didSelectItem`
/// 4. handlers of display state of cells (for example `willDisplayCell`) and layout of the
///    sections (insets, cell sizes)
/// 5. handler of a supplementary source. This object encapsulates header/footer logic.
/// 6. optional layout properties which are similar to the ones presented in `ListLayoutSource`.
///    Their use case is for complex layouts which are better to implement with several `ListLayoutSource`
///    objects just by picking the appropriate one for each IndexPath rather then having huge layout source
/// 7. methods to update items
/// 8. analytics context
public protocol ListSectionController: ListDisplayDelegate {

    var collection: ListCollectionContainer { get set }
    var numberOfItems: Int { get }

    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell
    func didSelectItem(at index: Int)

    /// Assign supplementary source to provide info of headers and footers in section.
    /// If no supplementary source provided - data source will use zero-height header and footer
    var supplementarySource: ListSupplementaryViewSource? { get set }

    /// Used by data source for `willDisplay` and `didEndDisplaying` methods
    /// Display delegate mostly used for pagination handling.
    var displayDelegate: ListDisplayDelegate? { get set }

    /// Is used to set the section's geometry - inset, size, spacing
    var layoutSource: ListLayoutSource? { get }

    /// Analytics related properties

    /// Optional to implement, once set, those properties will override layoutSource values
    /// They are useful when the layout consists of several layout kinds, so having one `ListLayoutSource`
    /// is not sufficient.
    var inset: UIEdgeInsets { get }
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
    func itemSize(at indexPath: IndexPath) -> CGSize

    /// Reload section items
    ///
    /// In order to have animated changes in the section, the controller should conform to
    /// `DiffableSectionController` protocol and implement diff logic.
    /// Diff calculations are handled by DeepDiff.framework.
    ///
    /// - Parameters:
    ///   - state: new state being applied to the section. If the section is able to reload itself
    ///            with animation - the changes are applied inside `batchUpdates` block
    ///   - completion: is called either after `batchUpdated` completed or right after section
    ///                 is reloaded without animations.
    func reload(with state: FeedState, completion: BoolBlock?)

    /// Indicates whether `reloadData` on parent collection view should be called on data update
    ///
    /// Set this as true in sections which instead of `reloadSections(indexOfSection)` expect
    /// `reloadData` to be called. It causes the full collection view reload
    /// Default value - false
    ///
    var reloadsCollectionViewOnUpdate: Bool { get }

    /// Update items without reload.
    ///
    /// Usually it's used right after section is created - we don't need animated updates for it so just insert items.
    ///
    /// - Warning:
    /// Use it only before the section is appeared onscreen. Once it's rendered - it's unsafe to change
    /// items because data source isn't aware of any updates there,
    /// so if you had 5 items then update it to 3 - you will surely get `index-out-of-bounds` expection.
    /// - Parameters:
    ///   - state: new state being applied to the section.
    func updateItems(_ state: FeedState)

}

/// Default implementation and helpers
extension ListSectionController {

    var supplementarySource: ListSupplementaryViewSource? {
        get { return nil }
        set {}
    }

    var layoutSource: ListLayoutSource? {
        get { return nil }
        set {}
    }

    /// Helpers
    func updateItems(_ items: [Any]) {
        self.updateItems(FeedState(items: items, loadingState: items.isEmpty ? .empty : .loadedAll))
    }

    /// Helper method which provides context of analytics for the section controller. Context includes data
    /// like section type, screen, search term, etc. that needs to be tracked along with events
    /// as payload dictionary
}

/// If list section controller adopts `DiffableSectionController` data source will use it as batch reload source
public protocol DiffableSectionController: AnyObject {
    func diffItems(_ newItems: [Any]) -> ChangeWithIndexPath?
}

public protocol ListDisplayDelegate: AnyObject {

    func willDisplayCell(_ cell: UICollectionViewCell, at index: Int)
    func didEndDisplayCell(_ cell: UICollectionViewCell, at index: Int)
}

// Abstract class
open class BaseListSectionController: NSObject, ListSectionController {

    open var collection: ListCollectionContainer = ListCollectionContainer(section: 0) {
        didSet {
            self.layoutSource?.container = collection
            self.supplementarySource?.collection = collection
            if collection.collectionView != nil, oldValue.collectionView != collection.collectionView {
                self.registerCells()
            }
        }
    }

    open var items: [Any] = []

    open var reloadsCollectionViewOnUpdate: Bool { return false }

    open var numberOfItems: Int {
        return items.count
    }

    public var name: String?

    // If `layoutSource` is not provided - inheriting class should override all layout related properties
    open var layoutSource: ListLayoutSource? {
        didSet {
            layoutSource?.container = collection
        }
    }

    open var supplementarySource: ListSupplementaryViewSource? = nil {
        didSet {
            supplementarySource?.collection = collection
        }
    }

    open var displayDelegate: ListDisplayDelegate? = nil

    public init(layoutSource: ListLayoutSource? = nil) {
        self.layoutSource = layoutSource
        super.init()
    }

    open func registerCells() {

    }

    open func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }

    open func updateItems(_ state: FeedState) {
        self.items = state.items
    }

    open func didSelectItem(at index: Int) {
        // Nothing
    }

    open func reload(with state: FeedState, completion: BoolBlock?) {
        // Default implementation - just reload section without batch updates
        let reloadInfo: BatchReloadInfo.Changes?
        if let diffable = self as? DiffableSectionController, (!self.items.isEmpty && !state.items.isEmpty) {
            reloadInfo = diffable.diffItems(state.items)
        } else {
            reloadInfo = nil
        }
        collection.reload(reloadInfo: reloadInfo, dataUpdateBlock: { [weak self] in
            self?.updateItems(state)
        }, completion: completion)

    }

    open var inset: UIEdgeInsets {
        layoutSource!.inset
    }

    open var minimumLineSpacing: CGFloat {
        return layoutSource!.minimumLineSpacing
    }

    open var minimumInteritemSpacing: CGFloat {
        return layoutSource!.minimumInteritemSpacing
    }

    open func itemSize(at indexPath: IndexPath) -> CGSize {
        return layoutSource!.itemSize(at: indexPath)
    }

    open func willDisplayCell(_ cell: UICollectionViewCell, at index: Int) {
        displayDelegate?.willDisplayCell(cell, at: index)
    }

    open func didEndDisplayCell(_ cell: UICollectionViewCell, at index: Int) {
        displayDelegate?.didEndDisplayCell(cell, at: index)
    }
}
