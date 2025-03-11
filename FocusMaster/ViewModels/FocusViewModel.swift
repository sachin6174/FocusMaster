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
    private let secondsToChangeBadgesAndPoints: Double  = 120

    init(persistenceController: PersistenceController = .shared, user: User? = nil) {
        self.persistenceController = persistenceController
        self.currentUser = user
    }

    func hasValidSavedSession() -> Bool {
        guard let state = SessionStateManager.shared.loadSession(),
            let user = currentUser,
            let userId = user.id,
            state.userID == userId
        else {
            return false
        }
        return true
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

        if let last = lastPointTime,
            currentTime.timeIntervalSince(last) >= secondsToChangeBadgesAndPoints
        {
            awardPoint()
            lastPointTime = currentTime
        }
        saveSessionState()
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

            // Create and configure badge
            let badge = Badge(context: context)
            badge.id = UUID()
            let randomBadge = BadgeType.randomBadge()
            badge.type = randomBadge.type
            badge.emoji = randomBadge.emoji

            // Update session points
            let newPoints = sessionInContext.points + 1
            sessionInContext.points = newPoints
            sessionInContext.addToBadges(badge)
            badge.session = sessionInContext

            // Update user total points
            let newTotalPoints = userInContext.totalPoints + 1
            userInContext.totalPoints = newTotalPoints
            userInContext.addToBadges(badge)
            badge.user = userInContext

            do {
                try context.save()

                DispatchQueue.main.async { [weak self] in
                    // Update the UI points counter
                    self?.points = Int(newPoints)

                    // Refresh the current user in main context to update stats
                    if let mainContext = self?.persistenceController.container.viewContext,
                        let refreshedUser = try? mainContext.existingObject(with: userObjectID)
                            as? User
                    {
                        self?.currentUser = refreshedUser
                    }
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    private func saveSessionState() {
        guard let session = currentSession,
            let mode = currentMode,
            let user = currentUser
        else { return }

        let state = SessionState(
            mode: mode.rawValue,
            elapsedTime: elapsedTime,
            points: points,
            sessionID: session.id ?? UUID(),
            startTime: session.startTime ?? Date(),
            userID: user.id ?? UUID()
        )
        SessionStateManager.shared.saveSession(state)
    }

    func restoreSession() {
        guard let state = SessionStateManager.shared.loadSession(),
            let user = currentUser,
            let userId = user.id,
            state.userID == userId
        else { return }

        let context = persistenceController.backgroundContext()

        context.perform {
            let session = Session(context: context)
            session.id = state.sessionID
            session.mode = state.mode
            session.startTime = state.startTime
            session.points = Int64(state.points)
            session.user = try? context.existingObject(with: user.objectID) as? User

            try? context.save()

            DispatchQueue.main.async {
                self.currentMode = FocusMode(rawValue: state.mode)
                self.currentSession = session
                self.elapsedTime = state.elapsedTime
                self.points = state.points
                self.startTimer()
            }
        }
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
        SessionStateManager.shared.clearSession()
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
