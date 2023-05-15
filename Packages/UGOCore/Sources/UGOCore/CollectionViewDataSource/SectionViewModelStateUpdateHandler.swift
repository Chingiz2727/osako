import Foundation

public enum DataListReloadType {
  case reload
  case none
  case batchReloadSingle(section: Int)
  case batchReload(indexPaths: ChangeSectionsWithIndexPath, dataUpdate: VoidBlock)
  case insertSections(sections: [Int])
  
    public var isInsert: Bool {
    switch self {
    case .insertSections: return true
    default: return false
    }
  }
  
    public var isBatchReload: Bool {
    switch self {
    case .batchReload: return true
    default: return false
    }
  }
}

public enum SectionDataSourceReload {
  case reload
  case insertSections(sections: [Int])
  case batchReload(indexPaths: ChangeSectionsWithIndexPath, dataUpdate: VoidBlock)
  
  
    public var isBatchReload: Bool {
    switch self {
    case .batchReload: return true
    default: return false
    }
  }
  
    public var isInsert: Bool {
    switch self {
    case .insertSections: return true
    default: return false
    }
  }
}

public protocol SectionViewModelsStateUpdateHandler: AnyObject {
  
  /// The associated data source
  var dataSource: SectionDataSource? { get set }
  
  /// Handler of a new section state
  ///
  /// In general it's a bridge between ViewModel layer (`FeedSectionsState`) and
  /// UI layer (`SectionDataSource` and `[ListSectionController]`).
  /// This method should handle updates of a view model's state, considering the `reloadType`,
  /// and providing to data source or reloading the Section Controllers.
  ///
  ///
  /// In most cases we use 1-to-1 mapping between `FeedSectionViewModel` i.e. view model and
  /// `ListSectionController` i.e. view. While `SectionControllerBuilder` (builder) acts as bridge
  /// between them - so that we keep less coupled code between view model and view.
  /// When the new update is present in view model of any section - we need either to reload
  /// the entire collection or reload the section (with or without batch updates).
  ///
  /// This is why we have `SectionViewModelsStateUpdateHandler` - for abstracting the reload logic
  /// because some screens may require excpetional rules of reload (like Comments screen, or Lite Home
  /// feed which are too complex for 1-to-1 mapping and it's better to handle them separately).
  ///
  /// But in most cases 1-to-1 mapping is ok and `FeedSectionViewModelsStateUpdateHandler` is the entity
  /// which covers most use cases. You can also use convenience method of `SectionDataSource` created
  /// with default parameters - `func updateSections(with: FeedSectionsState, reloadType: DataListReloadType)`
  /// which uses this feed section reloader as a helper class.
  ///
  func newState(_ feedSectionsState: FeedSectionsState, reloadType: DataListReloadType)
}

public class FeedSectionViewModelsStateUpdateHandler: SectionViewModelsStateUpdateHandler {
  
    public weak var dataSource: SectionDataSource?
  
  private var state: FeedSectionsState?
  
    public init() {
        
    }
    
    public func newState(_ feedSectionsState: FeedSectionsState, reloadType: DataListReloadType) {
    let viewModels = feedSectionsState.visibleSections
    
    var reloadType = reloadType
    if state?.visibleSections.count != feedSectionsState.visibleSections.count {
      reloadType = .reload
    }
    
    self.state = feedSectionsState
    
    switch reloadType {
    case .reload:
      /// In case of table view reload we build new section controllers unconditionally -
      /// that means the old controllers will be removed from memory.
      let sections = viewModels.map { (sectionViewModel: FeedSectionViewModel) -> ListSectionController in
        let sectionController: ListSectionController = sectionViewModel.buildSectionController()
        return sectionController
      }
      dataSource?.updateSections(sections: sections, reloadType: reloadType)
    case .insertSections:
      /// If the section controller is already created for some sections - reuse it
      /// If no - create a new section controller
      let sections = viewModels.map { (sectionViewModel: FeedSectionViewModel) -> ListSectionController in
        let sectionController: ListSectionController = sectionViewModel.sectionController ?? sectionViewModel.buildSectionController()
        return sectionController
      }
      dataSource?.updateSections(sections: sections, reloadType: reloadType)
    case .batchReloadSingle(let sectionIndex):
      /// Reloads the specified section controller either with plain `reloadSection` or animated `batchUpdated`
      /// which depends on whether section controller adapts to `DiffableSectionController` protocol
      if let section = dataSource?.sections.element(at: sectionIndex), let viewModel = viewModels.element(at: sectionIndex) {
        viewModel.sectionBuilder.configure(section)
        section.reload(with: viewModel.state, completion: nil)
      } else {
        self.newState(feedSectionsState, reloadType: .reload)
      }
    default:
      break
      
    }
  }
}
