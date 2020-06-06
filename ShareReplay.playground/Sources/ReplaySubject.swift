
////
//// hicham benhachem FST SETTAT
////
import Foundation
import Combine

public final class ReplaySubject<Output, Failure: Error>: Subject {
    private var buffer = [Output]()
    private let bufferSize: Int
    private var subscriptions = [ReplaySubjectSubscription<Output, Failure>]()
    private var completion: Subscribers.Completion<Failure>?
    private let lock = NSRecursiveLock()

    public init(_ bufferSize: Int = 0) {
        self.bufferSize = bufferSize
    }

    public func send(subscription: Subscription) {
        lock.lock(); defer { lock.unlock() }
        subscription.request(.unlimited)
    }


    public func send(_ value: Output) {
        lock.lock(); defer { lock.unlock() }
        buffer.append(value)
        buffer = buffer.suffix(bufferSize)
        subscriptions.forEach { $0.receive(value) }
    }


    public func send(completion: Subscribers.Completion<Failure>) {
        lock.lock(); defer { lock.unlock() }
        self.completion = completion
        subscriptions.forEach { subscription in subscription.receive(completion: completion) }
    }

   
    public func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
        lock.lock(); defer { lock.unlock() }
        let subscription = ReplaySubjectSubscription<Output, Failure>(downstream: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        subscriptions.append(subscription)
        subscription.replay(buffer, completion: completion)
    }
}
