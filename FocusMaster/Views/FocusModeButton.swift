//
//  FocusModeButton.swift
//  FocusMaster
//
//  Created by sachin kumar on 08/03/25.
//

import SwiftUI

struct FocusModeButton: View {
    let mode: FocusMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName(for: mode))
                    .font(.system(size: 30))
                Text(mode.rawValue)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }

    private func iconName(for mode: FocusMode) -> String {
        switch mode {
        case .work: return "briefcase.fill"
        case .play: return "gamecontroller.fill"
        case .rest: return "cup.and.saucer.fill"
        case .sleep: return "moon.fill"
        }
    }
}
