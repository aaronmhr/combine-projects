import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "NotificationCenter") {
    let center = NotificationCenter.default
    let myNotification = Notification.Name("MyNotification")

    let publisher = center
        .publisher(for: myNotification, object: nil)

    let subscription = publisher
        .print()
        .sink { _ in
            print("Notification received from a publisher!")
        }

    center.post(name: myNotification, object: nil)
    subscription.cancel()
}


example(of: "Just") {
    let just = Just("Hello World")
        .sink(receiveCompletion: {
            print("Reveived Completion:", $0)
        }, receiveValue: {
            print("Received Value", $0)
        })
        .store(in: &subscriptions)


}

example(of: "assign(to:on:)") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }

    let object = SomeObject()

    ["Hello", "World"].publisher
        .assign(to: \.value, on: object)
        .store(in: &subscriptions)
}

example(of: "PassthroughSubject") {
    let subject = PassthroughSubject<String, Never>()

    subject
        .sink(receiveValue: {print($0) })
        .store(in: &subscriptions)

    subject.send("Hello")
    subject.send("World")
    subject.send(completion: .finished)

    subject.send("Still there?")
}
