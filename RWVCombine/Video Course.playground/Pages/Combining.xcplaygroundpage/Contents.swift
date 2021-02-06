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

example(of: "prepend(output) - in depth") {
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
