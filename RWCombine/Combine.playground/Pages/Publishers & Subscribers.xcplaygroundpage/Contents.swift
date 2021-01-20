//: [Previous](@previous)

import Foundation
import Combine

example(of: "Publisher") {

    let myNotification = Notification.Name("MyNotification")

    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)

    let center = NotificationCenter.default

    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
        print("Notification Received!")
    }

    center.post(name: myNotification, object: nil)

    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")

    let publisher = NotificationCenter.default
        .publisher(for: myNotification)

    let center = NotificationCenter.default

    let subscription = publisher
        .sink { notification in
            print("Notification received from a publisher: \(notification)")
        }

    center.post(name: myNotification, object: nil)

    subscription.cancel()
}

example(of: "Just") {
    let just = Just("Hello World!")

    _ = just
        .sink(receiveCompletion: {
            print("Received completion ", $0)
        }, receiveValue: {
            print("Received value ", $0)
        })

    _ = just
        .sink(receiveCompletion: {
            print("Received completion (another)", $0)
        }, receiveValue: {
            print("Received value (another)", $0)
        })
}


example(of: "assign(to:on:") {
    class SomeObject {
        var value = "" {
            didSet { print(value) }
        }
    }

    let object = SomeObject()

    let publisher = ["Hello", "World"].publisher

    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher

    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .none
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }

    let subscriber = IntSubscriber()

    publisher.subscribe(subscriber)
}

example(of: "Hello Subject") {
    enum MyError: Error {
        case test
    }

    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            print("Receive value", input)

            return input == "World" ? .max(1): .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            print("Received completion", completion)
        }
    }

    let subscriber = StringSubscriber()

    let subject = PassthroughSubject<String, MyError>()

    subject.subscribe(subscriber)

    let subscription = subject
        .sink {completion in
            print("Received completion (sink)", completion)
        } receiveValue: { value in
            print("Received value (sink)", value)
        }

    subject.send("Hello")
    subject.send("World")

    subscription.cancel()

    subject.send("Still there?")

    subject.send(completion: .failure(.test))
    subject.send(completion: .finished)

    subject.send("How about another one?")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()

    let subject = CurrentValueSubject<Int, Never>(0)

    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    subject.send(1)
    subject.send(2)

    print("Printed", subject.value)

    subject.send(3)
    print("Printed", subject.value)

    subject
        .print()
        .sink(receiveValue: { print("Second subscription", $0) })
        .store(in: &subscriptions)

//    subject.value = .finished
    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)

            switch input {
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }

    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()

    subject.subscribe(subscriber)

    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type erasure") {
    var subscriptions = Set<AnyCancellable>()
    let subject = PassthroughSubject<Int, Never>()
    let publisher = subject.eraseToAnyPublisher()

    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    subject.send(0)
}
//: [Next](@next)
