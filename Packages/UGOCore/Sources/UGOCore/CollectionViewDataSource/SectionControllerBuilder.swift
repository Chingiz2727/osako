import Foundation

/// Intermideate instance which handles transformation of `SectionViewModel` to `ListSectionController`.
///
/// Using it's as a separate class instead of just having method
/// `createSectionController() -> SectionListController` inside viewModel removes tight coupling
/// between view model and view layers + we have cases when for a single view model we have several
/// sections
public protocol SectionControllerBuilder {
  
  /// Creates controller for a section
  func build(state: FeedState) -> ListSectionController
  
  /// Configuration method
  ///
  /// Use it to provide *reusable* configuration of a section controller
  /// For example, if the section has dynamic header which depends on amount of items
  /// configure controller's supplementary source in this method.
  /// Or, as in hashtags search section, the title of empty state UI depends on the
  /// search term.
  ///
  /// In contrast to `build(state:)` this method is called at every batch update/section reload
  ///
  func configure(_ controller: ListSectionController)
}

public typealias BaseListControllerBlock = ((ListSectionController) -> Void)

open class BaseSectionControllerBuilder: SectionControllerBuilder {
  
  /// Use the block to provide additional setup of the controller
  /// Will be called at the last step
  /// Note - call this closure in subclass controller setup
  public var configureControllerBlock: BaseListControllerBlock?
  
  public init(configureControllerBlock: BaseListControllerBlock?) {
    self.configureControllerBlock = configureControllerBlock
  }
  
  open func build(state: FeedState) -> ListSectionController {
    fatalError("Abstract class. Implement that method in concrete subclass")
  }
  
    open func configure(_ controller: ListSectionController) {
    configureControllerBlock?(controller)
  }
}
