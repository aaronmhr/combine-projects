import Combine
import SwiftUI
import PlaygroundSupport

let valuesPerSecond = 1.0
let collectTimeStride = 4.0

let sourcePublisher = PassthroughSubject<Date, Never>()

let collectPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    .flatMap { $0.publisher }

let subscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)

let sourceTimeline = TimelineView(title: "Emmitted values")
let collectedTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")

let view = VStack(spacing: 50) {
    sourceTimeline
    collectedTimeline
}
.padding(.bottom, 50)

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

sourcePublisher.displayEvents(in: sourceTimeline)
collectPublisher.displayEvents(in: collectedTimeline)
