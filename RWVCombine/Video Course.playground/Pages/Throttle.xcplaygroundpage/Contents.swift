import Combine
import SwiftUI
import PlaygroundSupport

let throttleDelay = 1.0
let subject = PassthroughSubject<String, Never>()

let throttled = subject
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: false)
    .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let throttledTimeline = TimelineView(title: "Throttled values")

let view = VStack(spacing: 50) {
    subjectTimeline

    throttledTimeline
}
.frame(width: 300, height: 300)

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
throttled.displayEvents(in: throttledTimeline)

let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emmited: \(string)")
    }

let subscription2 = throttled
    .sink { string in
        print("+\(deltaTime)s: Throttled emmited: \(string)")
    }

subject.feed(with: typingHelloWorld)
