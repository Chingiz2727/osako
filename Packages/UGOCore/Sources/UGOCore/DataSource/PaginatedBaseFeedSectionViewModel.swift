import Foundation

open class PaginatedBaseFeedSectionViewModel<Item>: BaseFeedSectionViewModel {

    public typealias DataProviderFactory = (_ cachePolicy: APICachePolicy, _ onUpdate: @escaping (PaginatedDataProviderState<Item>) -> Void) -> PaginatedDataProvider<Item>

    public var dataProvider: PaginatedDataProvider<Item>?

    /// Should be initialized prior to reload
    public var dataProviderBlock: DataProviderFactory!

    public init(sectionControllerBuilder: SectionControllerBuilder?, dataProviderBlock: DataProviderFactory?) {
        self.dataProviderBlock = dataProviderBlock
        super.init(sectionControllerBuilder: sectionControllerBuilder)
    }

    open override func buildSectionController() -> ListSectionController {
        let controller = super.buildSectionController()

        let paginationController = ListPaginationController<Item>(threshold: 4, dataProvider: dataProvider)
        paginationController.sectionController = controller
        controller.displayDelegate = paginationController

        return controller
    }
    
    open override func reloadData(cachePolicy: APICachePolicy) {
        print("[\(type(of: self)) reloadData")
        dataProvider = dataProviderBlock(cachePolicy) { [weak self] remoteState in
            guard let `self` = self else { return }
            print("[\(type(of: self)) remote state: \(remoteState.loadingState), source: \(String(describing: remoteState.source)), itemsCount: \(remoteState.items.count)]")
            var newValue = self.state
            if remoteState.loadingState.isLoaded {
                if remoteState.loadingState.isLoadedWithoutErrors {
                    newValue.items = remoteState.items
                }
            }
            newValue.loadingState = remoteState.loadingState

            let oldState = self.state
            self.state = newValue
            print("[\(type(of: self)) onUpdate, old: \(oldState.loadingState), new: \(newValue.loadingState)")
            DispatchQueue.main.async {
                self.onUpdate?((newValue, oldState))
            }
        }

        dataProvider?.reloadData()
    }

    open override func loadNext() {
        dataProvider?.loadNext()
    }
}
