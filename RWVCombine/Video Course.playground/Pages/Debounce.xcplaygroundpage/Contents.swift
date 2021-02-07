import Combine
import SwiftUI
import PlaygroundSupport

let subject = PassthroughSubject<String, Never>()

let debounced = subject
    .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
    .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let view = VStack(spacing: 50) {
    subjectTimeline

    debouncedTimeline
}
.frame(width: 300, height: 300)

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)

let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emmited: \(string)")
    }

let subscription2 = debounced
    .sink { string in
        print("+\(deltaTime)s: Debounced emmited: \(string)")
    }

subject.feed(with: typingHelloWorld)
