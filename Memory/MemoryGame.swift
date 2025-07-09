//
//  EmojiMemoryGameView.swift
//  Memory
//
import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: [Card] = []
    private(set) var score: Int = 0
    private var timer: Date = Date.now

    private var seenSet = Set<Card>()

    init(numberOfPairs: Int, cardFactory: (_ position: Int) -> CardContent) {
        for index in 0..<numberOfPairs {
            let content = cardFactory(index)
            cards.append(Card(content: content, id: "\(index)a"))
            cards.append(Card(content: content, id: "\(index)b"))
        }
        cards.shuffle()
    }

    struct Card: CustomStringConvertible, Equatable, Identifiable, Hashable {
        var isFaceUp = false
        var isMatched = false
        var content: CardContent
        var id: String

        static func == (lhs: MemoryGame<CardContent>.Card, rhs: MemoryGame<CardContent>.Card)
            -> Bool
        {
            return lhs.isFaceUp == rhs.isFaceUp && lhs.isMatched == rhs.isMatched
                && lhs.content == rhs.content
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var description: String {
            return "[\(content), \(isFaceUp ?  "up": "down"), \(isMatched), \(id)]"
        }

    }

    private var existingOpenCardIndex: Int? {
        get {
            let matchingIndex = cards.indices.filter { index in
                !cards[index].isMatched && cards[index].isFaceUp
            }.only
            return matchingIndex
        }

        set {
            cards.indices.forEach { i in
                if i == newValue {
                    cards[i].isFaceUp = true
                } else {
                    if !cards[i].isMatched {
                        cards[i].isFaceUp = false
                    }
                }
            }
        }
    }

    mutating private func adjustScore(by offset: Int) {
        score += offset
    }

    mutating func chose(card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        guard cards[chosenIndex].isFaceUp != true && cards[chosenIndex].isMatched != true else {
            return
        }

        guard let existingOpenIndex = existingOpenCardIndex else {
            existingOpenCardIndex = chosenIndex
            startTimer()
            return
        }

        if cards[existingOpenIndex].content == cards[chosenIndex].content {
            cards[existingOpenIndex].isMatched = true
            cards[chosenIndex].isMatched = true

            // Calculate match time penalty
            // min: 1 to avoid divison by 0
            let difference = clamp(value: resetTimerAndGetDifference(), min: 1, max: 5)
            let scoreAddition = 200 / difference
            adjustScore(by: scoreAddition)
        }

        if seenSet.contains(cards[chosenIndex]) || seenSet.contains(cards[existingOpenIndex]) {
            adjustScore(by: -100)
        }

        cards[chosenIndex].isFaceUp = true
        startTimer()
        seenSet.insert(card)
    }

    mutating func shuffle() {
        cards.shuffle()
        print(cards)
    }

    private mutating func startTimer() {
        timer = Date.now
    }

    private mutating func resetTimerAndGetDifference() -> Int {
        let nowDate = Date.now
        let difference = nowDate.timeIntervalSince(timer)
        timer = nowDate
        return Int(difference)
    }

    private func clamp<T: Comparable>(value: T, min: T, max: T?) -> T {
        if let max = max {
            return Swift.max(min, Swift.min(value, max))
        } else {
            return Swift.max(value, min)
        }
    }
}

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
