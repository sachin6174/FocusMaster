import Foundation

enum FocusMode: String, CaseIterable {
    case work = "Work"
    case play = "Play"
    case rest = "Rest"
    case sleep = "Sleep"
}

struct BadgeType {
    static let trees = ["🌵", "🎄", "🌲", "🌳", "🌴"]
    static let leavesAndFungi = ["🍂", "🍁", "🍄"]
    static let animals = ["🐅", "🦅", "🐵", "🐝"]

    static func randomBadge() -> (type: String, emoji: String) {
        let types = [
            (type: "trees", badges: trees),
            (type: "leavesAndFungi", badges: leavesAndFungi),
            (type: "animals", badges: animals),
        ]

        let randomType = types.randomElement()!
        let randomBadge = randomType.badges.randomElement()!
        return (type: randomType.type, emoji: randomBadge)
    }
}
