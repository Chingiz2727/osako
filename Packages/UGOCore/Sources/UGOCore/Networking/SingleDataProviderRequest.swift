import Foundation

class SingleDataProviderRequest {
    typealias RequestBlock = () -> (APITask?)
    
    var requestBlock: RequestBlock
    
    init(requestBlock: @escaping RequestBlock) {
        self.requestBlock = requestBlock
    }
}

/// No pagination version of `PaginatedDataProvider`
///
/// The main difference with `PaginatedDataProvider` is absence of `offset` and `limit`
/// Use this query for things that are 100% not paginated
/// For the implementation details - see PaginatedDataProvider.swift
class SingleDataProvider<Item>: NSObject {
    
    var state: SingleDataProviderState<Item> = SingleDataProviderState<Item>() {
        didSet {
            self.onUpdate(state)
        }
    }
    
    let maxAttemptsCount: Int
    private(set) var onUpdate: (SingleDataProviderState<Item>) -> Void
    
    private(set) var request: SingleDataProviderRequest?
    private var retryHandler: RetryHandler?
    private var currentRequest: APITask?
    
    init(maxAttemptsCount: Int = 3,
         onUpdate: @escaping (SingleDataProviderState<Item>) -> Void) {
        self.maxAttemptsCount = maxAttemptsCount
        self.onUpdate = onUpdate
        super.init()
    }
    
    deinit {
        print("[SingleDataProvider] deinit - will cancel request")
        currentRequest?.cancel()
    }
    
    func reloadData() {
        currentRequest?.cancel()
        state = SingleDataProviderState<Item>(loadingState: .loading, item: nil)
        makeRequest()
    }
    
    func handleError(_ error: Error?) {
        var newState = self.state
        newState.setResult(item: newState.item, error: error)
        self.state = newState
    }

    func setUpdateHandler(_ handler: @escaping (SingleDataProviderState<Item>) -> Void) {
        self.onUpdate = handler
    }

    private func makeRequest() {
        
        let request = makeRequest(result: { [weak self] result in
            switch result {
            case .success(let state):
                self?.state = state
            case .failure(let error):
                if self?.retryHandler?.haveAtempts == true {
                    self?.retryHandler?.performRetryBlock()
                } else {
                    print("[PaginatedDataProvider] don't have attempts - \(self?.retryHandler?.attemptsCount ?? 0), \(self?.retryHandler?.maxAttemptsCount ?? 0)")
                    self?.handleError(error)
                }
            }
        })
        self.request = request
        self.retryHandler = RetryHandler(maxAttemptsCount: maxAttemptsCount, mode: .exponential(constant: 4), executionBlock: { [weak self] in
            self?.currentRequest = self?.request?.requestBlock()
        })
        retryHandler?.performRetryBlock()
    }
    
    // Override in concrete classes - for new style data providers, which use benefits of retry handler
    func makeRequest(result: @escaping (Swift.Result<SingleDataProviderState<Item>, Error>) -> Void) -> SingleDataProviderRequest {
        fatalError()
    }
    
}
