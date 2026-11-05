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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
