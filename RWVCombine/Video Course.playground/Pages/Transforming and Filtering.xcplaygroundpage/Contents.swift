import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)
        .sink(receiveCompletion: { print("⚠️", $0) },
              receiveValue: { print("🔡", $0) })
        .store(in: &subscriptions)
}

example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    [123, 4, 56].publisher
        .map { formatter.string(from: NSNumber(value: $0)) ?? "❌"}
        .sink(receiveValue: { print("🔢", $0) })
        .store(in: &subscriptions)
}

example(of: "replaceNil") {
    ["a", nil, "b", "c"].publisher
        .replaceNil(with: "-")
        .map { $0! }
        .sink(receiveValue: { print("🔡", $0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()

    empty
        .replaceEmpty(with: 1)
        .sink(receiveValue: { print("🔢", $0) })
        .store(in: &subscriptions)
}


example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }

    let august = (0..<22)
        .map { _ in dailyGainLoss }

    let august2019 = august
        .publisher

    august2019
        .scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: { print("💵", $0) })
        .store(in: &subscriptions)
}


example(of: "flatMap") {
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
    let james = Chatter(name: "James", message: "Hi, I'm James!")
    let chris = Chatter(name: "Chris", message: "Hi, I'm Chris!")

    let chat = CurrentValueSubject<Chatter, Never>(charlotte)

    chat
        .flatMap { $0.message }
        .sink(receiveValue: { print("💬", $0) })
        .store(in: &subscriptions)

    charlotte.says("How's it going?")

    chat.value = james

    james.says("Doing great. You?")
    charlotte.says("I'm doing fine, thanks.")

    chat.send(completion: .finished)
    chat.value = chris

    chris.says("Sorry I'm late!!!! 😔")

    charlotte.says("Chat is not accepting anyone new, but I'm alive ✅")
    james.says("Me too ✅")

    james.message.send(completion: .finished)

    james.says("I disconnected by mistake ❌")
    charlotte.says("James, can you hear me? 📣")
}

example(of: "Create a phone number lookup") {
  let contacts = [
    "603-555-1234": "Florent",
    "408-555-4321": "Marin",
    "217-555-1212": "Scott",
    "212-555-3434": "Shai"
  ]

  func convert(phoneNumber: String) -> Int? {
    if let number = Int(phoneNumber),
      number < 10 {
      return number
    }

    let keyMap: [String: Int] = [
      "abc": 2, "def": 3, "ghi": 4,
      "jkl": 5, "mno": 6, "pqrs": 7,
      "tuv": 8, "wxyz": 9
    ]

    let converted = keyMap
      .filter { $0.key.contains(phoneNumber.lowercased()) }
      .map { $0.value }
      .first

    return converted
  }

  func format(digits: [Int]) -> String {
    var phone = digits.map(String.init)
                      .joined()

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 3)
    )

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 7)
    )

    return phone
  }

  func dial(phoneNumber: String) -> String {
    guard let contact = contacts[phoneNumber] else {
      return "Contact not found for \(phoneNumber)"
    }

    return "Dialing \(contact) (\(phoneNumber))..."
  }


    let input = PassthroughSubject<String, Never>()

    input
        .map(convert)
        .replaceNil(with: 0)
        .collect(10)
        .map(format)
        .map(dial)
        .sink(receiveValue: { print("☎️", $0)})

    "0!1234567".forEach {
      input.send(String($0))
    }

    "4085554321".forEach {
      input.send(String($0))
    }

    "A1BJKLDGEH".forEach {
      input.send("\($0)")
    }
}

example(of: "filter") {
    let numbers = (1...10).publisher

    numbers
        .filter { $0.isMultiple(of: 3) }
        .sink(receiveValue: { print("#️⃣ \($0) is a multiple of 3!")})
        .store(in: &subscriptions)
}
