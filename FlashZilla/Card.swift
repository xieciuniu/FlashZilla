//
//  Card.swift
//  FlashZilla
//
//  Created by Hubert Wojtowicz on 23/08/2023.
//

import Foundation

struct Card: Codable, Identifiable, Equatable {
    var id = UUID()
    let prompt: String
    let answer: String
    
    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
}
