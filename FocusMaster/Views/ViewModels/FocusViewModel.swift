//
//  FocusViewModel.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import Combine
import CoreData
import Foundation

class FocusViewModel: ObservableObject {
    @Published var currentMode: FocusMode?
    @Published var selectedMode: FocusMode?
    @Published var elapsedTime: TimeInterval = 0
    @Published var points: Int = 0
    @Published var currentSession: Session?

    private var timer: Timer?
    private let persistenceController: PersistenceController
    private var lastPointTime: Date?
    private var currentUser: User?

    init(persistenceController: PersistenceController = .shared, user: User? = nil) {
        self.persistenceController = persistenceController
        self.currentUser = user
        restoreSession()
    }

    func selectMode(_ mode: FocusMode) {
        selectedMode = mode
    }

    func startFocus() {
        guard let mode = selectedMode, let user = currentUser else { return }

        let context = persistenceController.backgroundContext()
        let userObjectID = user.objectID  // Store the objectID

        context.perform {
            guard let userInContext = try? context.existingObject(with: userObjectID) as? User
            else { return }

            let session = Session(context: context)
            session.id = UUID()
            session.mode = mode.rawValue
            session.startTime = Date()
            session.points = 0
            session.user = userInContext  // Use user from the same context

            try? context.save()

            DispatchQueue.main.async {
                self.currentMode = mode
                self.currentSession = session
                self.startTimer()
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.checkAndAwardPoints()
        }
    }

    private func checkAndAwardPoints() {
        let currentTime = Date()
        if lastPointTime == nil {
            lastPointTime = currentTime
        }

        if let last = lastPointTime, currentTime.timeIntervalSince(last) >= 120 {
            awardPoint()
            lastPointTime = currentTime
        }
    }

    private func awardPoint() {
        let context = persistenceController.backgroundContext()

        guard let session = currentSession,
            let user = currentUser
        else { return }

        let sessionObjectID = session.objectID
        let userObjectID = user.objectID

        context.perform {
            guard
                let sessionInContext = try? context.existingObject(with: sessionObjectID)
                    as? Session,
                let userInContext = try? context.existingObject(with: userObjectID) as? User
            else { return }

            let badge = Badge(context: context)
            badge.id = UUID()
            let randomBadge = BadgeType.randomBadge()
            badge.type = randomBadge.type
            badge.emoji = randomBadge.emoji

            sessionInContext.addToBadges(badge)
            sessionInContext.points += 1

            badge.user = userInContext
            userInContext.totalPoints += 1

            do {
                try context.save()
                // Ensure changes are reflected in view context
                DispatchQueue.main.async {
                    self.persistenceController.container.viewContext.refresh(
                        user, mergeChanges: true)
                }
            } catch {
                print("Error saving context: \(error)")
            }

            DispatchQueue.main.async {
                self.points += 1
            }
        }
    }

    private func restoreSession() {
        // Implement session restoration logic
    }

    func stopFocus() {
        let context = persistenceController.backgroundContext()

        guard let session = currentSession,
            let user = currentUser
        else { return }

        let sessionObjectID = session.objectID
        let userObjectID = user.objectID

        context.perform {
            guard
                let sessionInContext = try? context.existingObject(with: sessionObjectID)
                    as? Session,
                let userInContext = try? context.existingObject(with: userObjectID) as? User
            else { return }

            sessionInContext.duration = self.elapsedTime
            sessionInContext.user = userInContext

            try? context.save()

            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.timer = nil
                self.currentMode = nil
                self.currentSession = nil
                self.elapsedTime = 0
                self.points = 0
                self.lastPointTime = nil
            }
        }
    }

    func updateUser(_ user: User?) {
        self.currentUser = user
        // Reset current session if user changes
        if currentSession != nil {
            stopFocus()
        }
    }

    func deleteCurrentSession() {
        let context = persistenceController.backgroundContext()

        guard let session = currentSession else { return }
        let sessionObjectID = session.objectID

        context.perform {
            if let sessionToDelete = try? context.existingObject(with: sessionObjectID) {
                context.delete(sessionToDelete)
                try? context.save()
            }

            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.timer = nil
                self.currentMode = nil
                self.currentSession = nil
                self.elapsedTime = 0
                self.points = 0
                self.lastPointTime = nil
            }
        }
    }
}
