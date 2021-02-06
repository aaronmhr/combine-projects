import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "prepend(output)") {
    let publisher = [3,4].publisher

    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
