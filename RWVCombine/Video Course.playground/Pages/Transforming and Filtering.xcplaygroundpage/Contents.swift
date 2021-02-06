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


example(of: "flatMap") {
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
    let james = Chatter(name: "James", message: "Hi, I'm James!")
    let chris = Chatter(name: "Chris", message: "Hi, I'm Chris!")

    let chat = CurrentValueSubject<Chatter, Never>(charlotte)

    chat
        .flatMap { $0.message }
        .sink(receiveValue: { print("💬", $0) })
        .store(in: &subscriptions)

    charlotte.says("How's it going?")

    chat.value = james

    james.says("Doing great. You?")
    charlotte.says("I'm doing fine, thanks.")

    chat.send(completion: .finished)
    chat.value = chris

    chris.says("Sorry I'm late!!!! 😔")

    charlotte.says("Chat is not accepting anyone new, but I'm alive ✅")
    james.says("Me too ✅")

    james.message.send(completion: .finished)

    james.says("I disconnected by mistake ❌")
    charlotte.says("James, can you hear me? 📣")
}
