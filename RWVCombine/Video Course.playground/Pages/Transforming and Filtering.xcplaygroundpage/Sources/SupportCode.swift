import Combine

public struct Coordinate {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public func quadrantOf(x: Int, y: Int) -> String {
    var quadrant = ""

    switch (x, y) {
    case (1..., 1...):
        quadrant = "1"
    case (..<0, 1...):
        quadrant = "2"
    case (..<0, ..<0):
        quadrant = "3"
    case (1..., ..<0):
        quadrant = "4"
    default:
        quadrant = "boundary"
    }

    return quadrant
}

public struct Chatter {
    public let name: String
    public let message: CurrentValueSubject<String, Never>

    public init(name: String, message: String) {
        self.name = name
        self.message = CurrentValueSubject(Self.formatted(name: name, message: message))
    }

    public func says(_ message: String) {
        self.message.value = Self.formatted(name: name, message: message)
    }

    private static func formatted(name: String, message: String) -> String {
        name + ": " + message
    }
}
