//
//  SwitchUserView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct SwitchUserView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    @State private var newUsername = ""
    @State private var showingCreateUser = false

    var body: some View {
        NavigationView {
            VStack {
                // Create User Section
                Button(action: { showingCreateUser = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Create New User")
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
                .sheet(isPresented: $showingCreateUser) {
                    createUserView
                }

                Divider()

                // User List Section
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

    private var createUserView: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter Username", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    guard !newUsername.isEmpty else { return }
                    userManager.createUser(name: newUsername)
                    showingCreateUser = false
                    newUsername = ""
                }) {
                    Text("Create User")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(newUsername.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Create New User")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingCreateUser = false
                    }
                }
            }
        }
    }
}
