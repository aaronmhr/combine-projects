import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)
        .sink(receiveCompletion: { print("⚠️", $0) },
              receiveValue: { print("🔡", $0) })
        .store(in: &subscriptions)
}
