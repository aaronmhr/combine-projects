import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "prepend(Output)") {
    let publisher = [3,4].publisher

    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Output) - in depth") {
    let p0 = PassthroughSubject<Int, Never>()
    let p2 = PassthroughSubject<Int, Never>()
    let p3 = PassthroughSubject<Int, Never>()

    p0
        .prepend(100, 200)
        .prepend(p2)
        .prepend(p3)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    p0.send(0)
    p0.send(1)

    p2.send(10)
    p2.send(11)

    p3.send(20)
    p3.send(21)
    p3.send(completion: .finished)

    p2.send(12) // it doesnt begin to emit any value of p2 until p3 has finished
    p2.send(completion: .finished) // once p2 has finished it can begin to emit the values of prepend with variadic elements because it has definite size

    p0.send(2) // only then it can begin to emit p0 values
}

example(of: "prepend(Sequence)") {
    let publisher = [5,6,7].publisher

    publisher
        .prepend([3,4])
        .prepend(Set(1...2)) // some sequences have order other don't
        .prepend(stride(from: 6, through: 11, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher)") {
    let publisher1 = [3,4].publisher
    let publisher2 = [1,2].publisher

    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher) - #2") {
    let publisher1 = [3,4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()

    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

example(of: "append(Output)") {
    let publisher = [1].publisher

    publisher
        .append(2, 3)
        .append(4)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Output) #2") {
    let publisher = PassthroughSubject<Int, Never>()

    publisher
        .append(3,4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    let publisher = [1,2,3].publisher

    publisher
        .append([4,5])
        .append(Set(6...7)) // some sequences have order other don't
        .append(stride(from: 8, to: 11, by: 1))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher)") {
    let publisher1 = [1,2].publisher
    let publisher2 = [3,4].publisher

    publisher1
        .append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "Making Phone Numbers") {

    let phoneNumbersPublisher = ["123-4567"].publisher
    let areaCode = "410"
    let phoneExtension = "901"


    let numberPublisher = phoneNumbersPublisher
        .prepend(areaCode)
        .prepend("1")
        .collect()
        .map { $0.joined(separator: "-") }

    ["EXT"].publisher
        .append(phoneExtension)
        .prepend(numberPublisher)
        .collect()
        .sink(receiveValue: { print("1️⃣", $0.joined(separator: " ") ) })
        .store(in: &subscriptions)

    phoneNumbersPublisher
        .prepend("1-", areaCode, "-")
        .append(" EXT ")
        .append(phoneExtension)
        .collect()
        .sink(receiveValue: { print("2️⃣", $0.joined()) })
        .store(in: &subscriptions)

}

example(of: "switchToLatest") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<Int,Never>()
    let publisher3 = PassthroughSubject<Int,Never>()

    let publishers = PassthroughSubject<PassthroughSubject<Int,Never>,Never>()

    publishers
        .switchToLatest()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)

    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)

    publishers.send(publisher3)
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
}

example(of: "merge(with:)") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<Int,Never>()

    publisher1
        .merge(with: publisher2)
        .sink(
            receiveCompletion: { print("Completed", $0) },
            receiveValue: { print("🍡", $0) }
        )
        .store(in: &subscriptions)

    publisher1.send(1)
    publisher1.send(2)
    publisher2.send(3)
    publisher2.send(4)
    publisher1.send(5)

    publisher1.send(completion: .finished)
    publisher1.send(6)
    publisher2.send(7)

    publisher2.send(completion: .finished)
}

example(of: "combineLatest") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<String,Never>()

    publisher1
        .combineLatest(publisher2)
        .sink(
            receiveCompletion: { print("Completed", $0) },
            receiveValue: { print("🕣", $0) }
        )
        .store(in: &subscriptions)

    publisher1.send(1)
    publisher1.send(3)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")

    publisher1.send(completion: .finished)
    publisher1.send(4)
    publisher2.send("d")

    publisher2.send(completion: .finished)

}
