//
//  ContentView.swift
//  FlashZilla
//
//  Created by Hubert Wojtowicz on 23/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    // example stack of card
    @State private var cards = [Card]()
    
    // check if user use differentiate without color
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    // VoiceOver checker
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    
    // Adding timer
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // property to check if app is in background
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    // screen to editing card stack
    @State private var showingEditScreen = false
    
    var body: some View {
        ZStack {
            
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                //timer
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack {
                    ForEach(cards) { card in
                        CardView(card: card) { result in
                            withAnimation {
                                removeCard(at: card, result: result)
                                if cards.isEmpty {
                                    isActive = false
                                }
                            }
                        }
                            .stacked(at: card, in: cards)
                            .allowsHitTesting(cards.firstIndex(of: card) == cards.count - 1)
                            .accessibilityHidden(cards.firstIndex(of: card)! < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || voiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cards[cards.count - 1] , result: false)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                            }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect.")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: cards[cards.count - 1], result: true)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        // timer logic
        .onReceive(timer) { time in
            // stopping timer if scene is inactive
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        
        // check if scene is not inactive
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        
        // sheet to add card
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        
        // reseting cards when view appear for the first time
        .onAppear(perform: resetCards)
    }
    
    // method to remove card
    func removeCard(at card: Card, result: Bool) {
        //won't work if last card was removed
        if let index = try? cards.firstIndex(of: card) {
            guard index >= 0 else { return }
            
            if result {
                cards.remove(at: index)
            } else {
                let wrongCard = cards.remove(at: index)
                let newCard = Card(prompt: wrongCard.prompt, answer: wrongCard.answer)
                
                cards.insert(newCard, at: 0)
            }
        } else { return }
        
        
    }
    
    // method to reset questions
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    // method to get data from UserDefaults
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
        
        if let data = try? Data(contentsOf: FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")) {
            cards = try! JSONDecoder().decode([Card].self, from: data)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// extension to place card
extension View {
    func stacked(at position: Card, in total: [Card]) -> some View {
            let totalIndex = total.count
            if let positionIndex = try? total.firstIndex(of: position){
                let offset = Double(totalIndex - positionIndex)
                return self.offset(x: 0, y: offset * 10)
            }
            return self.offset(x: 0,y: 0)
    }
}
