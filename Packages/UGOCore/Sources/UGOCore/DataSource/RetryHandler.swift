import Foundation

/// Encapsulates retry logic
public final class RetryHandler {

    public enum Mode {
        case exponential(constant: Int)
        case linear(constant: Int)
    }

    public var haveAtempts: Bool {
        return attemptsCount < maxAttemptsCount
    }

    public let maxAttemptsCount: Int
    public let executionBlock: () -> ()
    private(set) var attemptsCount = 0
    private(set) var mode: Mode
    private(set) var queue: DispatchQueue

    public init(maxAttemptsCount: Int,
         mode: Mode = Mode.exponential(constant: 2),
         queue: DispatchQueue = DispatchQueue.main,
         executionBlock: @escaping () -> ()) {
        self.mode = mode
        self.maxAttemptsCount = maxAttemptsCount
        self.executionBlock = executionBlock
        self.queue = queue
    }

    public func clear() {
        attemptsCount = 0
    }

    /// Return value: true if max attempts count is less than current attempt
    @discardableResult
    public func performRetryBlock() -> Bool {
        if !haveAtempts {
            return false
        }

        let additionalTime = self.delay()
        self.attemptsCount = self.attemptsCount + 1
        if attemptsCount > 1 {
            NSLog("[RetryHandler] attempt: <\(self.attemptsCount)>")
        }
        if attemptsCount == 0 {
            executionBlock()
        } else {
            queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(additionalTime), execute: { [weak self] in
                self?.executionBlock()
            })
        }
        return true
    }

    public func delay() -> Int {
        switch mode {
        case .exponential(let constant):
            let exponent = self.exponent(constant: constant)
            return exponent
        case .linear(let constant):
            return constant
        }

    }

    private func exponent(constant: Int) -> Int {
        let attempt: Double = Double(attemptsCount)
        let constant: Double = Double(constant)
        return Int(pow(attempt, constant))
    }

}
