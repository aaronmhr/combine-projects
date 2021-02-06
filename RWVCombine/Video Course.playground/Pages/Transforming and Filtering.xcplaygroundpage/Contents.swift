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

example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    [123, 4, 56].publisher
        .map { formatter.string(from: NSNumber(value: $0)) ?? "❌"}
        .sink(receiveValue: { print("🔢", $0) })
        .store(in: &subscriptions)
}

example(of: "replaceNil") {
    ["a", nil, "b", "c"].publisher
        .replaceNil(with: "-")
        .map { $0! }
        .sink(receiveValue: { print("🔡", $0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()

    empty
        .replaceEmpty(with: 1)
        .sink(receiveValue: { print("🔢", $0) })
        .store(in: &subscriptions)
}


example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }

    let august = (0..<22)
        .map { _ in dailyGainLoss }

    let august2019 = august
        .publisher

    august2019
        .scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: { print("💵", $0) })
        .store(in: &subscriptions)
}
