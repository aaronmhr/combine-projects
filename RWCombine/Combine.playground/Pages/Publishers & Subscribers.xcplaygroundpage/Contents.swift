//: [Previous](@previous)

import Foundation

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


//: [Next](@next)
