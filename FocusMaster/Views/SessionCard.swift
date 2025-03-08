//
//  SessionCard.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct SessionCard: View {
    let session: Session
    let userManager: UserManager
    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(session.mode ?? "Unknown")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            Text("Duration: \(formattedDuration)")
            Text("Points: \(session.points)")
            Text("Started: \(session.startTime ?? Date(), style: .time)")

            if let badges = session.badges as? Set<Badge>, !badges.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(badges), id: \.id) { badge in
                            Text(badge.emoji ?? "")
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .alert("Delete Session", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                userManager.deleteSession(session)
            }
        } message: {
            Text("Are you sure you want to delete this session?")
        }
    }

    private var formattedDuration: String {
        let duration = Int(session.duration)
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
