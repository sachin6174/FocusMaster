//
//  FocusView.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct FocusView: View {
    @ObservedObject var focusViewModel: FocusViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text(focusViewModel.currentMode?.rawValue ?? "")
                .font(.largeTitle)
                .bold()

            Text(timeString(from: focusViewModel.elapsedTime))
                .font(.system(size: 60, weight: .medium, design: .monospaced))

            VStack {
                Text("Points: \(focusViewModel.points)")
                    .font(.title2)
            }
            .padding()

            Button(action: {
                focusViewModel.stopFocus()
            }) {
                Text("Stop Focusing")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
