//
//  UserManager.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import CoreData
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        loadCurrentUser()
    }

    func loadCurrentUser() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()

        if let users = try? context.fetch(request), let lastUser = users.last {
            currentUser = lastUser
        }
    }

    func createUser(name: String) {
        let context = persistenceController.backgroundContext()

        context.perform {
            let user = User(context: context)
            user.id = UUID()
            user.name = name
            user.totalPoints = 0

            try? context.save()

            DispatchQueue.main.async {
                self.loadCurrentUser()
            }
        }
    }

    func getAllUsers() -> [User] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func switchToUser(_ user: User) {
        let context = persistenceController.container.viewContext
        // Get fresh instance of user from current context
        let freshUser = try? context.existingObject(with: user.objectID) as? User
        if let freshUser = freshUser {
            currentUser = freshUser
        }
    }

    func deleteSession(_ session: Session) {
        let context = persistenceController.backgroundContext()
        let sessionID = session.objectID

        context.perform {
            guard let sessionToDelete = try? context.existingObject(with: sessionID) as? Session
            else { return }

            // Delete associated badges first
            if let badges = sessionToDelete.badges as? Set<Badge> {
                for badge in badges {
                    let points = sessionToDelete.points
                    // Update user's total points by subtracting session points
                    if let user = sessionToDelete.user {
                        user.totalPoints -= points
                    }
                    context.delete(badge)
                }
            }

            // Then delete the session
            context.delete(sessionToDelete)
            try? context.save()

            // Refresh current user to update stats
            if let currentUserID = self.currentUser?.objectID {
                DispatchQueue.main.async {
                    self.currentUser =
                        try? self.persistenceController.container.viewContext
                        .existingObject(with: currentUserID) as? User
                }
            }
        }
    }
}
