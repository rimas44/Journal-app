//
//  Untitled.swift
//  Journal app
//
//  Created by Rimas Alshahrani on 25/04/1446 AH.
//
import Foundation

// Namespace for your app
struct MyApp {
    // Model for a journal entry
    struct JournalEntry: Codable, Identifiable {
        var id: UUID = UUID()
        var title: String
        var content: String
        var isBookmarked: Bool = false
        var creationDate: Date = Date()
    }
}
