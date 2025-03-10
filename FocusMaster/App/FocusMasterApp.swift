//
//  FocusMasterApp.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

@main
struct FocusMasterApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
       DebugLogger.shared.log(message: "Starting App")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
