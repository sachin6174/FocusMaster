//
//  DebugLogger.swift
//  FocusMaster
//
//  Created by sachin kumar on 10/03/25.
//

import Foundation

final class DebugLogger {

    // MARK: - Singleton Instance
    static let shared = DebugLogger()

    // MARK: - Properties
    private let fileManager = FileManager.default
    private let logFileURL: URL
    private let logDateFormatter: DateFormatter

    // Add log levels
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case error = "ERROR"
    }

    // MARK: - Initialization
    private init() {
        // Create a timestamp for the file name, e.g., "20250310_153045"
        let fileDateFormatter = DateFormatter()
        fileDateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = fileDateFormatter.string(from: Date())

        // Create a file name that includes the app name and timestamp
        let fileName = "FocusMaster_\(timestamp).txt"

        // Get the URL for the app's Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        logFileURL = documentsDirectory.appendingPathComponent(fileName)

        // Initialize a date formatter for log entries with microseconds
        logDateFormatter = DateFormatter()
        logDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"

        // Create initial log file with header
        do {
            let header = "=== FocusMaster Log File Created at \(timestamp) ===\n"
            try header.write(to: logFileURL, atomically: true, encoding: .utf8)
            print("Log file created at: \(logFileURL.path)")
        } catch {
            print("Failed to create log file: \(error)")
        }
    }

    // MARK: - Logging Method
    /// Logs a message with details including timestamp, thread, file, and function.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The log level (defaults to .info).
    ///   - file: The file name from which the log is called (defaults to the caller’s file).
    ///   - function: The function name from which the log is called (defaults to the caller’s function).
    func log(
        message: String, level: LogLevel = .info, file: String = #file, function: String = #function
    ) {
        // Get timestamp with microseconds
        let timestamp = logDateFormatter.string(from: Date())
        let nanoTime = DispatchTime.now().uptimeNanoseconds
        let microseconds = (nanoTime / 1000) % 1_000_000
        let preciseTimestamp = "\(timestamp).\(String(format: "%06d", microseconds))"

        let threadName = Thread.isMainThread ? "Main" : "Background"
        let fileName = (file as NSString).lastPathComponent

        let logEntry =
            "[\(preciseTimestamp)] [\(level.rawValue)] [\(threadName)] [\(fileName)] [\(function)] - \(message)\n"
        print(logEntry)

        // Append the log entry to the file
        do {
            let data = logEntry.data(using: .utf8) ?? Data()
            if fileManager.fileExists(atPath: logFileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: logFileURL)
            }
        } catch {
            print("Failed to write log: \(error)")
        }
    }

    // Helper method to get log file URL
    func getLogFileURL() -> URL {
        return logFileURL
    }
}
