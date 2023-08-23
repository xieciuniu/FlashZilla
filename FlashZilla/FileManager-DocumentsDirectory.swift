//
//  FileManager-DocumentsDirectory.swift
//  FlashZilla
//
//  Created by Hubert Wojtowicz on 30/08/2023.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
