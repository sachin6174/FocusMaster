//
//  ContentView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WelcomeView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
