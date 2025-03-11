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
    @State private var hasSavedSession = false

    init(userManager: UserManager) {
        self.userManager = userManager
        self._focusViewModel = StateObject(
            wrappedValue: FocusViewModel(user: userManager.currentUser))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Focus Master")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    NavigationLink(destination: ProfileView(userManager: userManager)) {
                        VStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("See Badges")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 8)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 5)  // Reduced top padding from 10 to 5

                if let userName = userManager.currentUser?.name {
                    Text("Welcome, \(userName)")
                        .font(.headline)
                        .padding(.top)
                }

                if focusViewModel.currentMode != nil {
                    FocusView(focusViewModel: focusViewModel)
                } else {
                    if hasSavedSession && focusViewModel.hasValidSavedSession() {
                        Button(action: {
                            focusViewModel.restoreSession()
                        }) {
                            Text("Resume Previous Session")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 20)
                    }

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
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            hasSavedSession = SessionStateManager.shared.loadSession() != nil
        }
        .onChange(of: userManager.currentUser) { _, newUser in
            focusViewModel.updateUser(newUser)
        }
    }
}
