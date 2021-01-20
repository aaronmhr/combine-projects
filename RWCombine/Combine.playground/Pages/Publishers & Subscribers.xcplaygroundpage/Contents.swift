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

//: [Next](@next)
