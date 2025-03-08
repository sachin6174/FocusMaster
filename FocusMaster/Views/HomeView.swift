//
//  HomeView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var focusViewModel: FocusViewModel
    @ObservedObject var userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
        self._focusViewModel = StateObject(
            wrappedValue: FocusViewModel(user: userManager.currentUser))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let userName = userManager.currentUser?.name {
                    Text("Welcome, \(userName)")
                        .font(.headline)
                        .padding(.top)
                }

                if focusViewModel.currentMode != nil {
                    FocusView(focusViewModel: focusViewModel)
                } else {
                    Text("Choose Your Focus Mode")
                        .font(.title)
                        .padding()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20)
                    {
                        ForEach(FocusMode.allCases, id: \.self) { mode in
                            FocusModeButton(
                                mode: mode,
                                isSelected: focusViewModel.selectedMode == mode
                            ) {
                                focusViewModel.selectMode(mode)
                            }
                        }
                    }
                    .padding()

                    if focusViewModel.selectedMode != nil {
                        Button(action: {
                            focusViewModel.startFocus()
                        }) {
                            Text("Start Focus Session")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Focus Master")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView(userManager: userManager)) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
            }
        }
        .onChange(of: userManager.currentUser) { _, newUser in
            focusViewModel.updateUser(newUser)
        }
    }
}
