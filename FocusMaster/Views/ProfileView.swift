//
//  ProfileView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var userManager: UserManager
    @State private var showUserList = false
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.startTime, ascending: false)],
        animation: .default)
    private var sessions: FetchedResults<Session>

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Profile Section
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)

                    Text(userManager.currentUser?.name ?? "Unknown")
                        .font(.title)
                        .bold()

                    Button(action: { showUserList = true }) {
                        Text("Switch User")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Stats Section
                HStack(spacing: 40) {
                    VStack {
                        Text("\(totalPoints)")
                            .font(.title)
                        Text("Total Points")
                    }

                    VStack {
                        Text("\(totalBadges)")
                            .font(.title)
                        Text("Total Badges")
                    }
                }
                .padding()

                // Badges Section
                if !userBadges.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Your Badges")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(userBadges, id: \.id) { badge in
                                    Text(badge.emoji ?? "")
                                        .font(.system(size: 30))
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Recent Sessions Section
                VStack(alignment: .leading) {
                    Text("Recent Sessions")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(userSessions) { session in
                        SessionCard(session: session, userManager: userManager)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showUserList) {
            SwitchUserView(userManager: userManager)
        }
    }

    private var totalPoints: Int {
        let sessions = userManager.currentUser?.sessions?.allObjects as? [Session] ?? []
        return sessions.reduce(0) { $0 + Int($1.points) }
    }

    private var totalBadges: Int {
        userManager.currentUser?.badges?.count ?? 0
    }

    private var userBadges: [Badge] {
        (userManager.currentUser?.badges?.allObjects as? [Badge]) ?? []
    }

    private var userSessions: [Session] {
        (userManager.currentUser?.sessions?.allObjects as? [Session])?.sorted {
            ($0.startTime ?? Date()) > ($1.startTime ?? Date())
        } ?? []
    }
}
