import UIKit

public struct FeedState: CustomStringConvertible {
    
    /// Items of the state.
    /// We have them non-generic in order to not have each section controller/viewmodel generic
    public var items: [Any]
    
    /// The state of the section.
    public var loadingState: DataSourceStatus
    
    public typealias Update = (newValue: FeedState, oldValue: FeedState)
    
    public var description: String {
        return "loadingState: \(loadingState), itemsCount: \(items.count)"
    }
    
    public init(items: [Any], loadingState: DataSourceStatus) {
        self.items = items
        self.loadingState = loadingState
    }
}

// Main state object of any feed.
// Contains each section data provider as FeedSectionViewModel,
// so each section is loaded by each section view model entity
public class FeedSectionsState {
    
    public typealias InitBlock = (_ prevState: FeedSectionsState?) -> (FeedSectionsState)
    
    public var sections: [FeedSectionViewModel]
    
    // Convenience accessors
    public var visibleSections: [FeedSectionViewModel] {
        return sections.filter { $0.isVisible }
    }
    public var loadedSections: [FeedSectionViewModel] {
        return sections.filter { $0.state.loadingState.isLoaded }
    }
    
    public var isLoaded: Bool {
        for section in sections {
            if !section.state.loadingState.isLoaded {
                return false
            }
        }
        return true
    }
    
    public var onUpdated: ((_ sectionUpdated: FeedSectionViewModel, _ update: FeedState.Update) -> Void)?
    
    public init(sections: [FeedSectionViewModel]) {
        self.sections = sections
        self.sections.forEach { section in
            section.onUpdate = { [weak self] newValue in
                self?.onUpdated?(section, newValue)
            }
        }
    }
}

extension FeedSectionsState {
    public func sectionControllers() -> [ListSectionController] {
        return visibleSections.compactMap { $0.sectionController ?? $0.buildSectionController() }
    }
}

open class FeedViewModel: NSObject {
    
    // MARK: - Properties
    
    public var state: FeedSectionsState!
    
    /// This property should be initialized either  in .init or later before reloadData is called
    public var stateInitializator: FeedSectionsState.InitBlock?
    
    public var onStateUpdated: ((FeedSectionsState, DataListReloadType) -> (Void))?
    
    public var canReload: Bool {
        return state?.isLoaded ?? true
    }
    
    // MARK: - Lifecycle
    
    public init(stateInitializator: FeedSectionsState.InitBlock?) {
        self.stateInitializator = stateInitializator
        
        super.init()
    }
    
    open func reloadData(cachePolicy: APICachePolicy) {
        self.state = stateInitializator!(state == nil ? nil : state)
        
        state.onUpdated = { [weak self] (updatedSection: FeedSectionViewModel, update: FeedState.Update) in
            guard let `self` = self else { return }
            
            print("FeedViewModel new state")
            self.printState()
            print("uppdated \(String(describing: updatedSection.self)), updateOld: \(update.oldValue.items.count), updateNew: \(update.newValue.items.count)")
            
            // Quit early if the new state is `loading`
            if update.newValue.loadingState == .loading {
                return
            }
            
            let sectionToReload = self.calculateSectionToReload(updatedSection: updatedSection, update: update)
            
            self.stateUpdated(reloadSection: sectionToReload)
        }
        
        for section in state.sections {
            section.reloadData(cachePolicy: cachePolicy)
        }
        
    }
    
    // MARK: - Helpers
    
    private func printState() {
        print("\(self.state.sections.map { $0.state.loadingState })")
    }
    
    // TODO: - Make it simplier
    /// Basically we don't need such a complex logic.
    /// Currently it gets all `visibleSections`, find the index of the `updatedSection`, checks
    /// a few conditions like if the section was empty and provides us a index.
    /// Later this index is used to find appropriate SectionController and batchReload it
    /// The main point - we don't need this index. Just apply batch reload to a sectionController
    /// associated with this section - it's much cleared and removes possibility of messing up with
    /// indexes.
    open func calculateSectionToReload(updatedSection: FeedSectionViewModel, update: FeedState.Update) -> Int? {
        let newVisibleSections: [FeedSectionViewModel] = self.state.visibleSections
        var sectionToReload: Int?
        
        if updatedSection.state.items.isEmpty || update.oldValue.items.isEmpty {
            /// Force reload entire feed if previous state was `.empty`
            sectionToReload = nil
        } else if !updatedSection.state.loadingState.isLoaded && update.newValue.loadingState.isLoaded {
            /// Force reload entire feed if previous state was `.loading`
            sectionToReload = nil
        } else if updatedSection.isVisible == false {
            /// Force reload entire feed if section was invisible
            sectionToReload = nil
        } else {
            sectionToReload = newVisibleSections.firstIndex(where: { viewModel -> Bool in
                return viewModel === updatedSection
            })
        }
        return sectionToReload
    }
    
    // MARK: - State handling
    
    open func stateUpdated(reloadSection sectionToReload: Int? = nil) {
        print("[FeedViewModel updateState, loaded sections: \(state.loadedSections.count), isLoaded: \(String(describing: state))]")
        if let sectionToReload = sectionToReload {
            onStateUpdated?(self.state, DataListReloadType.batchReloadSingle(section: sectionToReload))
        } else {
            onStateUpdated?(self.state, DataListReloadType.reload)
        }
    }
    
}
