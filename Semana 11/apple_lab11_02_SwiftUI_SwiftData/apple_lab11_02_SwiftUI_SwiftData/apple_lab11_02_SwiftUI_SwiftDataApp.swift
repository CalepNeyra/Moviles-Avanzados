//
//  apple_lab11_02_SwiftUI_SwiftDataApp.swift
//  apple_lab11_02_SwiftUI_SwiftData
//
//  Created by Tecsup on 5/11/26.
//

import SwiftUI
import SwiftData

@main
struct apple_lab11_02_SwiftUI_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(ModelContainerProvider.shared.container)
        }
    }
}
