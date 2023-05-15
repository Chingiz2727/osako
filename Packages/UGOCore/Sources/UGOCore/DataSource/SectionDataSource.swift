import UIKit

/// Root class which maintains Data Source and Delegate of collection view
/// Each section is represented as `ListSectionController` which in order have info about
/// * items and their count in the section
/// * section layout info (inset, spacing, cell size)
/// * display handler (willDisplayCell, didDisplayCell)
/// * supplementary views (header, footer) layout logic
/// * didSelect method
public class SectionDataSource: NSObject {
    
    // MARK: - Properties
    private(set) var sections: [ListSectionController]
    private weak var collectionView: UICollectionView?
    private weak var viewController: UIViewController?
    
    private var proxyCollectionDelegate: CollectionViewDelegateProxy!
    private var proxyDelegate: ScrollViewDelegateProxy!
    
    private let reloader: CollectionViewReloader
    private let sectionReloader: CollectionViewSectionReloader
    private let batchReloader: CollectionViewBatchReloader
    
    /// Constructs default Data Source which has `DefaultCollectionViewReloader` as reloader, sectionReloader and feedSectionsHandler and an empty array of initial sections
    public static func `default`() -> SectionDataSource {
        let reloader = DefaultCollectionViewReloader()
        return SectionDataSource(commonReloader: reloader)
    }
    
    /// Main init
    ///
    ///
    /// - Parameters:
    ///   - sections: initial array of the sections, usually it's an empty array. Provide here sections
    ///               that needed to be shown initially. Default value empty is an empty array
    ///   - reloader: `CollectionViewReloader`, required
    ///   - sectionReloader: `CollectionViewSectionReloader`, required
    ///   - batchReloader: `CollectionViewBatchReloader`, required
    ///   - feedSectionsHandler: `SectionViewModelsStateUpdateHandler`. Default value is FeedSectionViewModelsStateUpdateHandler()
    public init(sections: [ListSectionController] = [],
         reloader: CollectionViewReloader,
         sectionReloader: CollectionViewSectionReloader,
         batchReloader: CollectionViewBatchReloader,
         feedSectionsHandler: SectionViewModelsStateUpdateHandler = FeedSectionViewModelsStateUpdateHandler()) {
        self.sections = sections
        self.reloader = reloader
        self.sectionReloader = sectionReloader
        self.batchReloader = batchReloader
        self.feedSectionsHandler = feedSectionsHandler
        
        super.init()
        
        self.feedSectionsHandler.dataSource = self
    }
    
    /// Convenience init
    ///
    /// If all the reloader protocols are implemented in a single entity (like in
    /// `DefaultCollectionViewReloader`) - use this initializer which accepts reloaders in one parameter
    /// - Parameters:
    ///   - sections: initial array of the sections, usually it's an empty array. Provide here sections
    ///               that needed to be shown initially. Default value empty is an empty array
    ///   - commonReloader: `CollectionViewReloader & CollectionViewSectionReloader & CollectionViewBatchReloader`, required
    ///   - feedSectionsHandler: `SectionViewModelsStateUpdateHandler`. Default value is FeedSectionViewModelsStateUpdateHandler()
    public convenience init(sections: [ListSectionController] = [],
                     commonReloader: CollectionViewReloader & CollectionViewSectionReloader & CollectionViewBatchReloader,
                     feedSectionsHandler: SectionViewModelsStateUpdateHandler = FeedSectionViewModelsStateUpdateHandler()) {
        self.init(sections: sections, reloader: commonReloader, sectionReloader: commonReloader, batchReloader: commonReloader, feedSectionsHandler: feedSectionsHandler)
    }
    
    public func setupView(collectionView: UICollectionView, controller: UIViewController) {
        self.reloader.collectionViewBlock = { collectionView }
        self.sectionReloader.collectionViewBlock = { collectionView }
        self.batchReloader.collectionViewBlock = { collectionView }
        self.collectionView = collectionView
        self.viewController = controller
        
        proxyCollectionDelegate = CollectionViewDelegateProxy()
        proxyDelegate = ScrollViewDelegateProxy()
        
        if let oldDelegate = (collectionView as UIScrollView).delegate {
            proxyDelegate.addDelegate(oldDelegate)
        }
        if let collectionOldDelegate = collectionView.delegate {
            proxyCollectionDelegate.addDelegate(collectionOldDelegate)
        }
        
        /// Initially configure each section controller with ListCollectionContainer object
        /// If there are any initial sections present
        sections.enumerated().forEach { sectionIndex, sectionController in
            var collection = ListCollectionContainer(section: sectionIndex,
                                                     collectionView: collectionView,
                                                     viewController: self.viewController)
            collection.reloadBlock = { [weak self] reloadInfo, dataUpdateBlock, completion in
                self?.reloadSection(sectionIndex, sectionController: sectionController, reloadInfo: reloadInfo, dataUpdateBlock: dataUpdateBlock, completion: completion)
            }
            sectionController.collection = collection
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    /// You can use two variants of updating data in data source
    /// 1. updateSections(withFeedState:) - more generic and abstracted version. All logic from
    ///    converting `FeedSectionsState` into data source `SectionController` is handled by
    ///    `feedSectionsHandler: SectionViewModelsStateUpdateHandler` and DataSource itself.
    /// 2. updateSections(section:) - you handle creation of `ListSectionController` by yourself
    ///    in most cases the flow is:
    ///    a) FeedViewModel - gets some data from query or combination of queries
    ///    b) ViewController - obtains `FeedSectionsState` from view model callback and uses
    ///       custom `SectionViewModelsStateUpdateHandler` to refresh UI
    ///    c) SectionViewModelsStateUpdateHandler - transfroms `FeedSectionsState` into list of
    ///       ListSectionControllers and triggers DataSource reload. (In case of batch reload of single
    ///       section, the reload is applying on the ListSectionController itself)
    
    // MARK: - Update with `FeedSectionsState` handling
    
    private let feedSectionsHandler: SectionViewModelsStateUpdateHandler
    
    public func updateSections(with feedState: FeedSectionsState, reloadType: DataListReloadType) {
        
        feedSectionsHandler.newState(feedState, reloadType: reloadType)
    }
    
    // MARK: - Update with section controllers handling
    
    /// Handles updates with section controllers array provided
    ///
    /// Supports next reload types: `.reload`, `.insertSections`, `.batchReload`
    /// Other cases should be handled outside of the data source
    ///
    public func updateSections(sections newSections: [ListSectionController], reloadType: DataListReloadType, completion: BoolBlock? = nil) {
        guard let collectionView = collectionView else {
            self.sections = newSections
            return
        }
        
        // 1. Update each section controller with fresh ListCollectionContainer object
        newSections.enumerated().forEach { sectionIndex, sectionController in
            var collection = ListCollectionContainer(section: sectionIndex,
                                                     collectionView: collectionView,
                                                     viewController: self.viewController)
            collection.reloadBlock = { [weak self] reloadInfo, dataUpdateBlock, completion in
                self?.reloadSection(sectionIndex, sectionController: sectionController, reloadInfo: reloadInfo, dataUpdateBlock: dataUpdateBlock, completion: completion)
            }
            sectionController.collection = collection
        }
        
        // 2. Force to reload entire collection view if amount of sections changed and it's not insert reload
        var reloadType = reloadType
        if newSections.count != self.sections.count && (!reloadType.isInsert && !reloadType.isBatchReload) {
            reloadType = .reload
        }
        
        // 3. Perform reload
        print("[FeedDataSource] reload with sections: \(sections.count), type: \(reloadType)")
        switch reloadType {
        case .reload:
            self.reloader.reloadCollectionView(dataUpdateBlock: {
                self.sections = newSections
            }, completion: completion)
        case .insertSections(let sections):
            self.sectionReloader.insertSections(sections, dataUpdateBlock: {
                self.sections = newSections
            }, completion: completion)
        case let .batchReload(indexPaths, dataUpdateBlock):
            self.batchReloader.reloadCollectionView(sectionChanges: indexPaths, dataUpdateBlock: {
                self.sections = newSections
                dataUpdateBlock()
            }, completion: completion)
        default:
            break
        }
    }
    
    private func reloadSection(_ sectionIndex: Int, sectionController: ListSectionController, reloadInfo: BatchReloadInfo.Changes?, dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock?) {
        if sectionController.reloadsCollectionViewOnUpdate {
            reloader.reloadCollectionView(dataUpdateBlock: dataUpdateBlock, completion: completion)
        } else {
            batchReloader.reloadCollectionView(changes: [BatchReloadInfo(changes: reloadInfo, section: sectionIndex)], dataUpdateBlock: dataUpdateBlock, completion: completion)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension SectionDataSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionModel = sections[section]
        return sectionModel.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        return section.cellForItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionModel = sections[indexPath.section]
        if let view = sectionModel.supplementarySource?.viewForSupplementaryElement(ofKind: kind, at: indexPath) {
            return view
        } else {
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: "emptyView")
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "emptyView", for: indexPath)
            return view
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SectionDataSource: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionModel = sections[section]
        return sectionModel.inset
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionModel = sections[indexPath.section]
        return sectionModel.itemSize(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionModel = sections[section]
        if let supplementarySource = sectionModel.supplementarySource, supplementarySource.supportedElementKinds.contains(UICollectionView.elementKindSectionHeader) {
            return supplementarySource.sizeForSupplementaryView(of: UICollectionView.elementKindSectionHeader)
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionModel = sections[section]
        if let supplementarySource = sectionModel.supplementarySource, supplementarySource.supportedElementKinds.contains(UICollectionView.elementKindSectionFooter) {
            return supplementarySource.sizeForSupplementaryView(of: UICollectionView.elementKindSectionFooter)
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionModel = sections[section]
        return sectionModel.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionModel = sections[section]
        return sectionModel.minimumInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionModel = sections[indexPath.section]
        sectionModel.didSelectItem(at: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let sectionModel = sections.element(at: indexPath.section) {
            sectionModel.willDisplayCell(cell, at: indexPath.row)
            proxyCollectionDelegate.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let sectionModel = sections.element(at: indexPath.section) {
            sectionModel.didEndDisplayCell(cell, at: indexPath.row)
        }
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        proxyDelegate.scrollViewDidScroll(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        proxyDelegate.scrollViewWillBeginDragging(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        proxyDelegate.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        proxyDelegate.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        proxyDelegate.scrollViewDidEndDecelerating(scrollView)
    }
}

