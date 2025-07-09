//
//  EmojiMemoryGameView.swift
//  Memory
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String>

    private(set) var currentTheme: Theme

    init(themeName: String = "spooky") {
        currentTheme = EmojiMemoryGame.themes[themeName]!
        model = EmojiMemoryGame.createEmojiGame(using: currentTheme)
    }

    static private let themes: [String: Theme] = [
        "spooky": Theme(
            name: "spooky", color: AnyShapeStyle(Color.black),
            emojis: ["👻", "🎃", "🕸️", "🧛", "🕷️", "🧟", "🪦"], numberOfPairs: 4),
        "nature": Theme(
            name: "nature", color: AnyShapeStyle(Color.green),
            emojis: ["🌲", "🌻", "🌈", "🌼", "🍄", "🐦", "📷"], numberOfPairs: 2),
        "space": Theme(
            name: "space", color: AnyShapeStyle(Color.orange),
            emojis: ["🚀", "🛸", "🪐", "🌕", "🌠", "☄️", "👾"], numberOfPairs: 7),
        "hearts": Theme(
            name: "hearts",
            color: AnyShapeStyle(
                LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)),
            emojis: ["💘", "💝", "💖", "💗", "💓", "💞", "💕", "💟", "❣️", "💔", "❤️", "🍋"]),
    ]

    private static func createEmojiGame(using theme: Theme) -> MemoryGame<String> {
        let numberOfPairs: Int = theme.numberOfPairs ?? Int.random(in: 2..<theme.emojis.count)

        return MemoryGame<String>(numberOfPairs: numberOfPairs) { index in
            return theme.emojis.indices.contains(index) ? theme.emojis[index] : "N/A"
        }
    }

    private func choseRandomTheme() {
        if let theme = EmojiMemoryGame.themes.values.randomElement() {
            currentTheme = theme
        }
    }

    struct Theme {
        let name: String
        let color: AnyShapeStyle
        let emojis: [String]
        var numberOfPairs: Int?
    }

    var cards: [MemoryGame<String>.Card] {
        return model.cards
    }

    var score: String {
        String(model.score)
    }

    func chose(_ card: MemoryGame<String>.Card) {
        model.chose(card: card)
    }

    func shuffle() {
        model.shuffle()
    }

    func startNewGame() {
        choseRandomTheme()
        model = EmojiMemoryGame.createEmojiGame(using: currentTheme)
    }
}
