//
//  EmojiMemoryGameView.swift
//  Memory
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel = EmojiMemoryGame()

    var body: some View {
        VStack {
            Text("Memorize!").font(.largeTitle)
            Text(viewModel.currentTheme.name).font(.largeTitle)
            Text(viewModel.score).font(.largeTitle)
            card().animation(.default, value: viewModel.cards)
        }.padding()

        Spacer()
        HStack {
            Button {
                viewModel.shuffle()
            } label: {
                Text("Shuffle")
            }
            Spacer()
            Button {
                viewModel.startNewGame()
            } label: {
                Text("New Game")
            }
        }.padding()
    }

    func card() -> some View {
        return GeometryReader { geometry in
            let sizeThatFits = computeSizeThatFits(
                size: geometry.size, aspectRatio: 2 / 3, cardCount: viewModel.cards.count)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: sizeThatFits))]) {
                ForEach(viewModel.cards) { card in
                    cardView(card: card, color: viewModel.currentTheme.color).aspectRatio(
                        2 / 3, contentMode: .fit
                    ).onTapGesture {
                        viewModel.chose(card)
                    }
                }

            }
        }
    }

    func computeSizeThatFits(size: CGSize, aspectRatio: CGFloat, cardCount: Int) -> CGFloat {
        let cardCount = CGFloat(cardCount)
        var columnCount = 1.0

        repeat {
            let width = size.width / columnCount
            let height = width / aspectRatio
            let rowCount = (cardCount / columnCount).rounded(FloatingPointRoundingRule.up)

            if height * rowCount + 10 < size.height {
                return (size.width / columnCount).rounded(.down)
            }
            columnCount += 1
        } while columnCount < cardCount
        return size.width / cardCount
    }

}

struct cardView: View {
    let card: MemoryGame<String>.Card
    let color: AnyShapeStyle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color).foregroundStyle(color)
            Group {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white).padding(2)
                Text(card.content)
                    .font(.largeTitle)
            }.opacity(card.isFaceUp ? 1 : 0)
        }.opacity(card.isMatched ? 0 : 1).animation(.easeInOut(duration: 1), value: card.isMatched)
    }
}

#Preview {
    EmojiMemoryGameView()
}

struct CardView_Preview: PreviewProvider {
    static var previews: some View {
        HStack {
            cardView(
                card: MemoryGame.Card(isFaceUp: true, content: "O", id: "test"),
                color: AnyShapeStyle(Color.orange))
            cardView(
                card: MemoryGame.Card(isFaceUp: false, content: "O", id: "test"),
                color: AnyShapeStyle(Color.orange))
        }
    }

}
