//
//  ContentView.swift
//  MemoryGame
//
//  Created by Christopher Petit on 3/3/25.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}

class MemoryGameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    
    private var selectedIndices: [Int] = []
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        let symbols = ["🔥", "🍀", "💦", "🌍", "💨","☀️","👽","💯","👨🏾‍🎓"]
        let pairedSymbols = (symbols + symbols).shuffled()
        
        cards = pairedSymbols.map { Card(content: $0) }
        selectedIndices.removeAll()
    }
    
    func flipCard(at index: Int) {
        guard !cards[index].isFlipped, !cards[index].isMatched else { return }
        
        cards[index].isFlipped.toggle()
        selectedIndices.append(index)
        
        if selectedIndices.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        let firstIndex = selectedIndices[0]
        let secondIndex = selectedIndices[1]
        
        if cards[firstIndex].content == cards[secondIndex].content {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.cards[firstIndex].isMatched = true
                self.cards[secondIndex].isMatched = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.cards[firstIndex].isFlipped = false
                self.cards[secondIndex].isFlipped = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.selectedIndices.removeAll()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    
    var body: some View {
        ZStack {
            //stretch feature
            Color.gray.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        
                    }) {
                        Text("Choose Size")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.startNewGame()
                    }){
                        Text("Reset Game")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding()
                }
                //stretch feature
                ScrollView{
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                        ForEach(viewModel.cards.indices, id: \ .self) { index in
                            CardView(card: viewModel.cards[index])
                                .onTapGesture {
                                    viewModel.flipCard(at: index)
                                }
                        }
                    }
                }
                .padding(25)
            }
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            if card.isMatched {
                Color.clear
            }
            else if card.isFlipped {
                Text(card.content)
                    .font(.largeTitle)
                    .frame(width: 125, height: 175)
                    .border(Color.black, width: 3)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 125, height: 175)
                    .cornerRadius(10)
            }
        }
    }
}

@main
struct MemoryGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
