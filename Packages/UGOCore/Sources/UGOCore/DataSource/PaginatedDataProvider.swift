
import Foundation

/// Encapsulates Request block
public class DataProviderRequest {
    public typealias RequestBlock = ((_ offset: Int) -> (APITask?))
    
    public var requestBlock: RequestBlock
    
    public init(requestBlock: @escaping RequestBlock) {
        self.requestBlock = requestBlock
    }
    
    public static var empty: DataProviderRequest {
        return DataProviderRequest(requestBlock: { offset in return nil })
    }
}

/// A helper class to abstract out client-server data requests.
///
/// Abstracts Request related info into `PaginatedDataProviderState`, helps to maintain
/// pagination of the queries (limit, offset), contains
open class PaginatedDataProvider<Item>: NSObject {
    
    /// The actual state object
    public var state: PaginatedDataProviderState<Item> {
        didSet {
            self.onUpdate(state)
        }
    }
    
    /// Limit of a query
    public let limit: Int
    
    /// The initial offset. There are cases when we don't start right from 0 offset.
    public let startOffset: Int
    
    /// Cache policy of a query.
    public let cachePolicy: APICachePolicy
    
    /// Callback which is called every time when the state is changed
    public var onUpdate: (PaginatedDataProviderState<Item>) -> Void
    
    /// The currently running request
    private(set) var request: DataProviderRequest?
    
    // MARK: - Retry-on-error related properties
    
    /// How many attempts data provider will do if it encounters error.
    /// Default value - 2.
    public let maxAttemptsCount: Int
    
    /// Helper object which provides retry on error logic.
    private var retryHandler: RetryHandler?
    
    public var currentRequest: APITask?
    
    /// Items used to pre-populate the data provider. They are inserted at first reload only.
    private var initialItems: [Item]
    
    /// Used to flag a first load of the data so data provider can set `initialItems` as
    /// pre-populated items on first load.
    private var isFirstReload: Bool = true
    
    /// Helper property which checks whether it's possible to perform a next page loading.
    open var hasMoreData: Bool {
        return state.loadingState == .ready
    }
    
    public init(initialItems: [Item] = [],
         limit: Int = 100,
         startOffset: Int = 0,
         cachePolicy: APICachePolicy = APICachePolicy.returnCacheDataElseFetch,
         maxAttemptsCount: Int = 2,
         onUpdate: @escaping (PaginatedDataProviderState<Item>) -> Void) {
        self.state = PaginatedDataProviderState<Item>(loadingState: .notReady, items: initialItems, offset: startOffset)
        self.initialItems = initialItems
        self.limit = limit
        self.cachePolicy = cachePolicy
        self.startOffset = startOffset
        self.maxAttemptsCount = maxAttemptsCount
        self.onUpdate = onUpdate
        super.init()
    }
    
    deinit {
        print("[PaginatedDataProvider] deinit - will cancel request")
        currentRequest?.cancel()
    }
    
    /// Reloads the data provider from initial offset.
    ///
    /// Calls `makeRequest` method with the `startOffset` value.
    ///
    /// - Parameters:
    ///   - userInfo: An optional dictionary to be provided into `userInfo` of a State object.
    ///               You may use it to give an additional context for State object.
    ///
    /// - Note: sets items of the state to be either empty array or `initialItems` in case
    ///         of first load request.
    /// - Note: cancels the current performing task
    /// - Note: sets the loading state to `.loading`
    ///
    open func reloadData(userInfo: [String: DataProviderExtraInfo] = [:]) {
        currentRequest?.cancel()
        state = PaginatedDataProviderState<Item>(loadingState: .loading,
                                                 items: isFirstReload ? initialItems : [],
                                                 offset: startOffset,
                                                 userInfo: userInfo)
        makeRequest(offset: startOffset)
        isFirstReload = false
    }
    
    /// Loads next page of data, if possible.
    ///
    /// Makes sure it's possible to load next chunk of data by checking `isLoading` value of
    /// a dataProvider's state.
    /// Additionaly, in case of `.returnCacheDataAndFetch` cache policy we enforce loading of
    /// the next page to be from server. Thus we check the previous loaded page whether it's
    /// from server, if so - perform load of the next page.
    ///
    /// - Note: cancels the current performing task
    /// - Note: sets the loading state to `.loading`
    open func loadNext() {
        guard !state.isLoading else { return }
        
        if cachePolicy == .returnCacheDataAndFetch, state.source == .cache {
            /// Ignore `loadNext` trigger until we get data from the server for the current range
            return
        }
        
        currentRequest?.cancel()
        state.loadingState = .loading
        makeRequest(offset: state.offset + limit)
    }
    
    /// Helper method which handles errors for us
    ///
    /// Sets the loading state to `.error` and assigns an error's object to the state
    /// so it can be used as ViewController/ViewModel to handle concrete errors
    open func handleError(_ error: Error?) {
        var newState = self.state
        newState.loadingState = .error
        newState.error = error
        self.state = newState
    }
    
    /// Performs loading of a request.
    ///
    /// This is internal implementation and can't be overriden.
    /// Basically it wraps `makeRequest(resultHandler:_)` in a Retry handling logic and handles
    /// result from the same method.
    /// If the result is `.success` - assigns the new state to `self.state`
    /// If the result is `.failure` - tries to perform reload once more, if the retry handler has
    /// more attempts. If there are no possible attempts - calls `handleError(_:)` method which,
    /// in turn, handles the error object.
    final func makeRequest(offset: Int) {
        
        let request = makeRequest(resultHandler: { [weak self] result in
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
            self?.currentRequest = self?.request?.requestBlock(offset)
        })
        retryHandler?.performRetryBlock()
    }
    
    /// Performs loading of a request.
    ///
    /// The method should perform an actual request.
    /// In the body of this method you should create `DataProviderRequest` object which does
    /// the typical `api.performQuery()` thing in `requestBlock`.
    ///
    /// - Parameters:
    ///   - resultHandler: a closure which takes `Swift.Result` value with either new State provided
    ///                    or an Error object. You should always use this closure as an end point
    ///                    of any request - so that Data Provider will always be in a correct state
    ///                    according to the query response.
    ///
    /// - Returns: `DataProviderRequest` object containing information relative to a query. It's used then to
    ///            perform a query with appropriate offset.
    ///
    ///
    /// - Important: Should be overriden in subclasses.
    open func makeRequest(resultHandler: @escaping (Swift.Result<PaginatedDataProviderState<Item>, Error>) -> Void) -> DataProviderRequest {
        fatalError()
    }
    
    // MARK: - Helpers
    
    /// Helper which handles new Items from the API correctly.
    ///
    /// Takes all the related to the response info and handles appropriate state mutation with
    /// calling `result` block with either a new state or an error.
    ///
    /// - Parameters:
    ///   - items: New items from the API response. Provide only new items, not all. For example
    ///            if the query returned items from offset 20 with limit 10 - you don't need to
    ///            provide items from 0 to 20 indexes.
    ///   - offset: Offset of a completed query
    ///   - error: If the query failed - provide the error
    ///   - source: Source of the response (`.cache | .server`)
    ///   - result: resultHandler block which is provided in `makeRequest` method, you can pass up
    ///             your own result Handler block, but in this case you should handle the original
    ///             `resultHandler` block from `makeRequest` yourself.
    ///
    open func handleItemsHelper(_ items: [Item]?, offset: Int, error: Error?, source: APIResponseSource?, result: @escaping (Result<PaginatedDataProviderState<Item>, Error>) -> Void) {
        if let items = items {
            let currentState = self.state
            var newState: PaginatedDataProviderState<Item> = currentState
            
            if offset == currentState.offset {
                newState.updateItems(items, limit: limit, offset: offset)
            } else {
                newState = currentState.appending(items, limit: limit)
            }
            newState.error = nil
            newState.source = source
            result(.success(newState))
        } else {
            result(.failure(error!))
        }
    }
}
