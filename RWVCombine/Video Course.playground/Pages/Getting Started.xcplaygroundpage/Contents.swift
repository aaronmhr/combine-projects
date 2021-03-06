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
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    subject.send("Hello")
    subject.send("World")
    subject.send(completion: .finished)

    subject.send("Still there?")
}

example(of: "CurrentValueSubject") {
    let subject = CurrentValueSubject<Int, Never>(0)

    subject
        .print()
        .sink(receiveValue: { print("🍌", $0) })
        .store(in: &subscriptions)

    print("🍏", subject.value)

    subject.send(1)
    subject.send(2)

    print("🍎", subject.value)

    subject.send(completion: .finished)
}

example(of: "Type erasure") {
    let subject = PassthroughSubject<Int, Never>()

    let publisher = subject.eraseToAnyPublisher()

    publisher
        .sink(receiveValue: { print("🧼", $0) })
        .store(in: &subscriptions)

//    publisher.send(0)

    subject.send(0)
    subject.send(completion: .finished)
}


example(of: "Create a Blackjack card dealer") {
    let dealtHand = PassthroughSubject<Hand, HandError>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = 52
        var hand = Hand()

        for _ in 0 ..< cardCount {
            let randomIndex = Int.random(in: 0 ..< cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        if hand.points > 21 {
            dealtHand.send(completion: .failure(.busted))
        } else {
            dealtHand.send(hand)
        }
    }

    dealtHand
        .sink {
            if case let .failure(error) = $0 {
                print(error)
            }
        } receiveValue: { hand in
            print(hand.cardString, "for", hand.points, "points")
        }
        .store(in: &subscriptions)

    deal(3)
}
