//
//  journal app .swift
//  Journal app
//
//  Created by Rimas Alshahrani on 18/04/1446 AH.
import SwiftUI

// Model for a journal entry
struct JournalEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var isBookmarked: Bool = false
    var creationDate: Date = Date() // Automatically captures the date the entry is created
}

struct JournalAppView: View {
    @State private var filterOption: String = "None"
    @State private var showNewJournalSheet: Bool = false // State to control sheet visibility
    @State private var journalEntries: [JournalEntry] = [] // Array to hold journal entries
    @State private var searchText: String = "" // State variable for the search text
    @State private var showingEditSheet: Bool = false // State for showing edit sheet
    @State private var selectedJournal: JournalEntry? // To keep track of selected journal entry for editing

    // Computed property to filter journal entries based on search text
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return journalEntries // Return all entries if search text is empty
        } else {
            return journalEntries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                // Header Section with Title and Menu Button
                HStack {
                    Text("Journal")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    // Menu Button for Filtration
                    Menu {
                        // Filter by Bookmark
                        Button(action: {
                            filterOption = "Bookmark"
                            applyFilter(option: filterOption)
                        }) {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                        
                        // Filter by Journal Date
                        Button(action: {
                            filterOption = "Journal Date"
                            applyFilter(option: filterOption)
                        }) {
                            Label("Journal Date", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease")
                            .font(.title)
                            .foregroundColor(.lavender)
                            .padding(12)
                            .background(Circle().fill(Color.gray.opacity(0.4)))
                    }
                    
                    // Add New Journal Button
                    Button(action: {
                        showNewJournalSheet.toggle() // Toggle the sheet visibility
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.lavender)
                            .font(.title)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.4)))
                    }
                }
                .padding()
                .background(Color.black)
                
                // Search Bar with Icons
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("  Search...", text: $searchText)
                        .padding(.vertical, 9)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Spacer()
                                Button(action: {
                                    // Action for voice recorder (placeholder)
                                    print("Voice recorder tapped")
                                }) {
                                    Image(systemName: "mic.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // If there are no entries, show the default image
                if filteredEntries.isEmpty {
                    Image("book1") // Make sure "book1" image exists in your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 77.7, height: 101)
                        .padding()
                    
                    Text("Begin Your Journal")
                        .padding(10)
                        .bold()
                        .foregroundColor(.lavender)
                        .fontWeight(.heavy)
                        .font(.system(size: 25))
                    
                    Text("Craft your personal diary, \ntap the plus icon to begin")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                } else {
                    // Display saved journal entries
                    List {
                        ForEach(filteredEntries) { entry in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(entry.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.lavender)
                                    
                                    Spacer()
                                    Button(action: {
                                        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
                                            journalEntries[index].isBookmarked.toggle()
                                            saveEntries() // Save after bookmarking
                                        }
                                    }) {
                                        Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                                            .font(.system(size: 24))
                                            .foregroundColor(.lavender)
                                    }
                                }
                                Text(formatDate(entry.creationDate)) // Use creationDate here
                                    .font(.subheadline)
                                Text(entry.content)
                                    .font(.body)
                            }
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    selectedJournal = entry // Set the selected journal for editing
                                    showingEditSheet.toggle() // Show the editing sheet
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .tint(.purple) // Changed tint to a valid color
                            }
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    onDelete(entry: entry)
                                }) {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listRowSpacing(15) // Set the spacing between rows to 15 points
                }
                
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showNewJournalSheet) {
                NewJournalSheet(journalEntries: $journalEntries, formatDate: formatDate) // Pass journalEntries and formatDate to the sheet
            }
            .sheet(isPresented: $showingEditSheet) {
                if let entry = selectedJournal {
                    NewJournalSheet(journalEntries: $journalEntries, selectedEntry: entry, formatDate: formatDate) // Pass selected entry and formatDate for editing
                        .onDisappear {
                            selectedJournal = nil // Reset the selected journal
                        }
                }
            }
        }
        .onAppear {
            loadEntries() // Load entries when the view appears
        }
    }
    
    // Function to format date
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Function to handle filtering logic
    func applyFilter(option: String) {
        print("Filter applied: \(option)")
    }
    
    // Load entries from UserDefaults
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries") {
            if let entries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
                journalEntries = entries
            }
        }
    }

    // Save entries to UserDefaults
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }

    // Define onDelete function
    func onDelete(entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveEntries() // Ensure entries are saved after deletion
    }
}

struct NewJournalSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var journalEntries: [JournalEntry] // Use Binding to modify journalEntries
    @State private var journalTitle: String = ""
    @State private var journalContent: String = ""
    @State private var isBookmarked: Bool = false
    var selectedEntry: JournalEntry? // Optional entry for editing
    var formatDate: (Date) -> String // Closure to format date

    var body: some View {
        VStack {
            // Header with Cancel and Save buttons
            HStack {
                Button("cancel") {
                    dismiss() // Dismiss the sheet
                }
                .foregroundColor(.lavender)
                
                Spacer()
                
                Button("Save") {
                    saveEntry() // Call save function
                    dismiss() // Dismiss after saving
                }
                .foregroundColor(.lavender)
            }
            .padding()

            // Title input styled as per the screenshot
            TextField("Title", text: $journalTitle)
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
                .bold()
            
            // Date display
            Text(formatDate(Date())) // Dynamically display the current date
                .foregroundColor(.gray)
                .padding(.trailing, 250)

            // Journal entry input
            TextField("Enter your journal", text: $journalContent)
                .padding()
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Set values if editing an existing entry
            if let entry = selectedEntry {
                journalTitle = entry.title
                journalContent = entry.content
                isBookmarked = entry.isBookmarked
            }
        }
    }
    
    // Save journal entry to UserDefaults
    private func saveEntry() {
        // Validate that the title and content are not empty
        guard !journalTitle.isEmpty && !journalContent.isEmpty else {
            return
        }

        // Create a new entry
        let newEntry = JournalEntry(title: journalTitle, content: journalContent, isBookmarked: isBookmarked)

        // If editing an existing entry, replace it
        if let selectedEntry = selectedEntry {
            if let index = journalEntries.firstIndex(where: { $0.id == selectedEntry.id }) {
                journalEntries[index] = newEntry // Replace the existing entry
            }
        } else {
            // Add the new entry to the journalEntries array
            journalEntries.append(newEntry)
        }

        // Save updated entries to UserDefaults
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }
}


struct JournalAppView_Previews: PreviewProvider {
    static var previews: some View {
        JournalAppView()
    }
}
