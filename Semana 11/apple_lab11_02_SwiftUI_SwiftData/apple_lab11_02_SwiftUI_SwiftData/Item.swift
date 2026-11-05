//
//  Item.swift
//  apple_lab11_02_SwiftUI_SwiftData
//
//  Created by Tecsup on 5/11/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
