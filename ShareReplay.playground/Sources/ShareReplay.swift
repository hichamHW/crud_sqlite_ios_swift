import Foundation
import Combine

extension Publisher {
   ////
//// hicham benhachem FST SETTAT
////
    public func shareReplay(_ bufferSize: Int) -> AnyPublisher<Output, Failure> {
        return multicast(subject: ReplaySubject(bufferSize)).autoconnect().eraseToAnyPublisher()
    }
}
