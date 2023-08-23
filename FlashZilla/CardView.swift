//
//  CardView.swift
//  FlashZilla
//
//  Created by Hubert Wojtowicz on 23/08/2023.
//

import SwiftUI

struct CardView: View {
    // card struct
    let card: Card
    
    // removal closure
    var removal: ((Bool) -> Void)? = nil
    
    // property to show answer
    @State private var isShowingAnswer = false
    
    // adding drag ability for cards
    @State private var offset = CGSize.zero
    
    // checking if there is turned on accessibility for colour blind people
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    // haptic generator
    @State private var feedback = UINotificationFeedbackGenerator()
    
    // VoiceOver checker
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    
    // is successed
    @State private var success = true
    
    
    var body: some View {
        
        // View
        ZStack {
            // Card
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? .white
                    : .white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset == .zero ? .white : offset.width > 0 ? .green : .blue)
                )
                .shadow(radius: 10)
            
            // Card text
            VStack {
                if voiceOverEnabled {
                    
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                } else {
                    
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        //moving cards
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        // accessibility will work with buttons
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    
                    // warming up haptic engines
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        // haptic feedback
                        if offset.width > 0 {
                            //feedback.notificationOccurred(.success)
                            success = true
                        } else {
                            feedback.notificationOccurred(.error)
                            success = false
                        }
                        
                        // remove the card
                        removal?(success)
                        
                    } else {
                        offset = .zero
                    }
                }
        )
        
        .onTapGesture {
            withAnimation{
                isShowingAnswer.toggle()
            }
        }
        
        // animation when card go back to stack
        .animation(.spring(), value: offset)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
