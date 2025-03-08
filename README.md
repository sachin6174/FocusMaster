# 📱 User Focus & Productivity App

## 📝 Overview

The **User Focus & Productivity App** helps users stay productive by allowing them to enter predefined focus modes, track their focus time, and earn rewards.

## 🎯 Features

- **Four Focus Modes:** Work, Play, Rest, and Sleep.
- **Timer System:**
  - Shows time in `00:00` format.
  - Switches to `00:00:00` after one hour.
- **Reward System:**
  - Every 2 minutes of focus earns a point and a badge.
  - Random badges assigned from the following categories:
    - 🌳 Trees: [🌵, 🎄, 🌲, 🌳, 🌴]
    - 🍂 Leaves & Fungi: [🍂, 🍁, 🍄]
    - 🐅 Animals: [🐅, 🦅, 🐵, 🐝]
- **Persistent Sessions:**
  - The session remains active even if the app is closed.
  - Points and session data are preserved.
- **Profile View:**
  - Displays user image, name, total points, earned badges, and session history.

## 📌 Profile Layout

- **User Image (Centered)**
- **User Name**
- **Total Points Earned**
- **Total Badges Collected**
- **Recent Sessions:**
  - Session Name
  - Duration
  - Points Earned
  - Start Time

## ⚙️ Core Data Implementation

- **All data operations are performed in a background thread.**
- **Merge policy ensures auto-merge with parent context to prevent data loss.**

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- Swift 5+
- iOS 15+

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/focus-productivity-app.git
   ```
2. Open the project in Xcode:
   ```sh
   cd focus-productivity-app
   open FocusProductivity.xcodeproj
   ```
3. Build and run the app:
   - Select the target device/emulator.
   - Press `Cmd + R`.

## 🏆 How It Works

1. **Select a Focus Mode**
2. **Start Focusing**
3. **Earn Points & Badges** every 2 minutes
4. **Stop Focusing** manually
5. **View Your Progress** in the Profile section

## 🎨 App Icon

- A sleek and modern design featuring a stopwatch/timer symbol with natural elements (trees, leaves, moon, etc.) to indicate focus modes.

## 📌 Edge Cases Handled

- **App Closure:** Restores the last active focus session.
- **Data Loss Prevention:** Ensures points and sessions are saved properly.

---

🚀 Stay focused and boost your productivity! 🔥

