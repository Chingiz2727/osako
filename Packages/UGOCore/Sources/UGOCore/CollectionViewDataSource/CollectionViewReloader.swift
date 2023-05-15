import UIKit

public struct BatchReloadInfo {
    public typealias Changes = ChangeWithIndexPath
    
    public let changes: Changes?
    public let section: Int
}

public typealias VoidBlock = () -> ()
public typealias BoolBlock = (Bool) -> Void

public typealias CollectionViewRetrieveBlock = (() -> UICollectionView)

public protocol CollectionViewReloader: AnyObject {
    var collectionViewBlock: CollectionViewRetrieveBlock? { get set }
    func reloadCollectionView(dataUpdateBlock: VoidBlock, completion: BoolBlock?)
}

public protocol CollectionViewSectionReloader: AnyObject {
    var collectionViewBlock: CollectionViewRetrieveBlock? { get set }
    func insertSections(_ sections: [Int], dataUpdateBlock: VoidBlock, completion: BoolBlock?)
}

public protocol CollectionViewBatchReloader: AnyObject {
    var collectionViewBlock: CollectionViewRetrieveBlock? { get set }
    func reloadCollectionView(changes: [BatchReloadInfo], dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock?)
    func reloadCollectionView(sectionChanges: ChangeSectionsWithIndexPath, dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock?)
}

extension DefaultCollectionViewReloader {
    
    public struct PendingBatchUpdate {
        public let changes: [BatchReloadInfo]
        public let dataUpdateBlock: VoidBlock
        public let completion: BoolBlock?
    }
    
    public struct PendingReload {
        public let dataUpdateBlock: VoidBlock
        public let completion: BoolBlock?
    }
}

public class DefaultCollectionViewReloader: CollectionViewReloader & CollectionViewSectionReloader & CollectionViewBatchReloader {
    
    public var collectionViewBlock: CollectionViewRetrieveBlock?
    private var isBatchUpdateInProgress = false
    private var pendingBatchUpdates: [PendingBatchUpdate] = []
    private var pendingReloads: [PendingReload] = []
    
    public init(collectionViewBlock: CollectionViewRetrieveBlock? = nil) {
        self.collectionViewBlock = collectionViewBlock
    }
    
    public func insertSections(_ sections: [Int], dataUpdateBlock: VoidBlock, completion: BoolBlock? = nil) {
        guard let collectionView = collectionViewBlock?() else { return }
        dataUpdateBlock()
        collectionView.insertSections(IndexSet(sections))
        collectionView.layoutIfNeeded()
        completion?(true)
    }
    
    public func reloadCollectionView(dataUpdateBlock: VoidBlock, completion: BoolBlock? = nil) {
        guard let collectionView = collectionViewBlock?() else { return }
        dataUpdateBlock()
        collectionView.setNeedsLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        completion?(true)
    }
    
    
    /// Batch Updates. `DeepDiff` framework is used as source
    
    public func reloadCollectionView(changes: [BatchReloadInfo], dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock? = nil) {
        
        guard let collectionView = self.collectionViewBlock?() else { return }
        
        if changes.contains(where: { $0.changes != nil }) {
            if changes.contains(where: { $0.changes?.hasChanges == true }) {
                self.batchUpdatesBegin()
                collectionView.performBatchUpdates({
                    dataUpdateBlock()
                    let notNilChanges = changes.compactMap { $0.changes }
                    notNilChanges.forEach { reloadInfo in
                        self.insideUpdate(changesWithIndexPath: reloadInfo, collectionView: collectionView)
                    }
                }, completion: { [weak self] finished in
                    self?.batchUpdatesCompleted()
                    completion?(finished)
                    if finished {
                        DispatchQueue.main.async {
                            self?.queuePendingBatchUpdateIfNeeded()
                        }
                    }
                })
                
                changes.compactMap { $0.changes }.forEach { reloadInfo in
                    guard reloadInfo.hasChanges else { return }
                    // reloadRows needs to be called outside the batch
                    self.outsideUpdate(changesWithIndexPath: reloadInfo, collectionView: collectionView)
                }
            } else {
                // No changes, no need to reload
            }
        } else {
            dataUpdateBlock()
            collectionView.reloadSections(IndexSet(changes.map { $0.section }))
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
            completion?(true)
        }
        
    }
    
    
    // MARK: - Updates Helpers
    
    private func insideUpdate(changesWithIndexPath: ChangeWithIndexPath, collectionView: UICollectionView) {
        changesWithIndexPath.deletes.executeIfPresent {
            collectionView.deleteItems(at: $0)
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            collectionView.insertItems(at: $0)
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }
    }
    
    private func outsideUpdate(changesWithIndexPath: ChangeWithIndexPath, collectionView: UICollectionView) {
        changesWithIndexPath.replaces.executeIfPresent {
            collectionView.reloadItems(at: $0)
        }
    }
    
    // MARK: - Section helpers
    
    
    public func reloadCollectionView(sectionChanges: ChangeSectionsWithIndexPath, dataUpdateBlock: @escaping VoidBlock, completion: BoolBlock? = nil) {
        
        guard let collectionView = self.collectionViewBlock?() else { return }
        
        if sectionChanges.hasChanges {
            
            guard !self.isBatchUpdateInProgress else {
                print("[CollectionViewReloader] trying to perform batch updates while another in progress")
                self.addPendingReload(PendingReload(dataUpdateBlock: dataUpdateBlock, completion: completion))
                return
            }
            
            let completion: (Bool) -> Void = { [weak self] finished in
                self?.batchUpdatesCompleted()
                completion?(finished)
                if finished {
                    DispatchQueue.main.async {
                        if self?.queuePendingReloadIfNeeded() == false {
                            // Queue batch updates in case if we don't have pending reload
                            self?.queuePendingBatchUpdateIfNeeded()
                        }
                    }
                }
            }
            self.batchUpdatesBegin()
            collectionView.performBatchUpdates({
                dataUpdateBlock()
                self.insideSectionUpdate(changesWithIndexPath: sectionChanges, collectionView: collectionView)
                
                // Workaround on not called completion block
                // http://www.openradar.me/48941363
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(true)
                }
            }, completion: nil)
            
            let change = ChangeWithIndexPath(sectionChanges: sectionChanges)
            // reloadRows needs to be called outside the batch
            self.outsideUpdate(changesWithIndexPath: change, collectionView: collectionView)
        }
    }
    
    private func insideSectionUpdate(changesWithIndexPath: ChangeSectionsWithIndexPath, collectionView: UICollectionView) {
        changesWithIndexPath.deletesSections.executeIfPresent {
            collectionView.deleteSections(IndexSet($0))
        }
        
        changesWithIndexPath.insertsSections.executeIfPresent {
            collectionView.insertSections(IndexSet($0))
        }
        
        changesWithIndexPath.movesSections.executeIfPresent {
            $0.forEach { move in
                collectionView.moveSection(move.from, toSection: move.to)
            }
        }
        
        // copy of insideUpdate(changesWithIndexPath: ChangeWithIndexPath
        changesWithIndexPath.deletesItems.executeIfPresent {
            collectionView.deleteItems(at: $0)
        }
        
        changesWithIndexPath.insertsItems.executeIfPresent {
            collectionView.insertItems(at: $0)
        }
        
        changesWithIndexPath.movesItems.executeIfPresent {
            $0.forEach { move in
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }
        
    }
}

// MARK: - State handling
extension DefaultCollectionViewReloader {
    
    
    private func batchUpdatesBegin() {
        isBatchUpdateInProgress = true
    }
    
    private func batchUpdatesCompleted() {
        isBatchUpdateInProgress = false
    }
    
    private func queuePendingReloadIfNeeded() -> Bool {
        guard !pendingReloads.isEmpty else { return false }
        
        let reload = pendingReloads.removeFirst()
        self.reloadCollectionView(dataUpdateBlock: reload.dataUpdateBlock, completion: reload.completion)
        self.pendingBatchUpdates.removeAll()
        return true
    }
    
    private func queuePendingBatchUpdateIfNeeded() {
        guard !pendingBatchUpdates.isEmpty else { return }
        
        let batchUpdate = pendingBatchUpdates.removeFirst()
        print("[CollectionViewReloader] have pending batch updates - perform one of them")
        self.reloadCollectionView(changes: batchUpdate.changes, dataUpdateBlock: batchUpdate.dataUpdateBlock, completion: batchUpdate.completion)
    }
    
    private func addPendingBatchUpdate(_ batchUpdate: PendingBatchUpdate) {
        pendingBatchUpdates.append(batchUpdate)
    }
    
    private func addPendingReload(_ reload: PendingReload) {
        pendingReloads.append(reload)
    }
}

/// This is a enhanced version of DeepDiff's `ChangeWithIndexPath` which has
/// missed support for sections. Used it in Comments screen because each comment is a
/// section and we needed to handle batch updates of them
public struct ChangeSectionsWithIndexPath {
    
    public let insertsSections: [Int]
    public let deletesSections: [Int]
    public let movesSections: [(from: Int, to: Int)]
    public let updatedSections: [Int]
    
    public let insertsItems: [IndexPath]
    public let deletesItems: [IndexPath]
    public let movesItems: [(from: IndexPath, to: IndexPath)]
    public let updatesItems: [IndexPath]
    
    public init(
        insertsSections: [Int] = [],
        deletesSections: [Int] = [],
        movesSections: [(from: Int, to: Int)] = [],
        updatedSections: [Int] = [],
        insertsItems: [IndexPath] = [],
        deletesItems: [IndexPath] = [],
        updatesItems:[IndexPath] = [],
        movesItems: [(from: IndexPath, to: IndexPath)] = []) {
            
            self.insertsSections = insertsSections
            self.movesSections = movesSections
            self.updatedSections = updatedSections
            self.deletesSections = deletesSections
            
            self.insertsItems = insertsItems
            self.deletesItems = deletesItems
            self.updatesItems = updatesItems
            self.movesItems = movesItems
        }
    
    public var hasChanges: Bool {
        let sections = !insertsSections.isEmpty || !deletesSections.isEmpty || !movesSections.isEmpty || !updatedSections.isEmpty
        let items = !insertsItems.isEmpty || !deletesItems.isEmpty || !movesItems.isEmpty || !updatesItems.isEmpty
        return sections || items
    }
}

extension ChangeWithIndexPath {
    public init(sectionChanges: ChangeSectionsWithIndexPath) {
        self = ChangeWithIndexPath(inserts: sectionChanges.insertsItems, deletes: sectionChanges.deletesItems, replaces: sectionChanges.updatesItems, moves: sectionChanges.movesItems)
    }
    
    public var hasChanges: Bool {
        return !inserts.isEmpty || !deletes.isEmpty || !replaces.isEmpty || !moves.isEmpty
    }
}
