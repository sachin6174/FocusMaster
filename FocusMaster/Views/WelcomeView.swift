//
//  WelcomeView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var userManager = UserManager()
    @State private var newUsername = ""

    var body: some View {
        VStack(spacing: 30) {
            if userManager.currentUser != nil {
                HomeView(userManager: userManager)
            } else {
                welcomeContent
            }
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 30) {
            Text("Welcome to Focus Master")
                .font(.largeTitle)
                .bold()

            Text("Please enter your name to begin")
                .font(.title3)

            TextField("Your Name", text: $newUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 50)

            Button(action: {
                guard !newUsername.isEmpty else { return }
                userManager.createUser(name: newUsername)
            }) {
                Text("Start Focusing")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(newUsername.isEmpty)
        }
    }
}

struct UserListView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(userManager.getAllUsers(), id: \.id) { user in
                Button(action: {
                    userManager.switchToUser(user)
                    dismiss()
                }) {
                    HStack {
                        Text(user.name ?? "Unknown")
                        Spacer()
                        if user.id == userManager.currentUser?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Switch User")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
