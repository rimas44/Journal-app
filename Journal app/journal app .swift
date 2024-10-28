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
    @State private var entryToEdit: JournalEntry? = nil // State to hold entry being edited
    
    // Computed property to filter journal entries based on search text
    var filteredEntries: [JournalEntry] {
        let entries = filterOption == "Bookmark"
            ? journalEntries.filter { $0.isBookmarked }
            : journalEntries
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            // Header Section with Title and Menu Button
            HStack {
                Text("Journal")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    // Menu Button for Filtration
                    Menu {
                        Button(action: {
                            filterOption = "Bookmark"
                            applyFilter(option: filterOption)
                        }) {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                        
                        Button(action: {
                            filterOption = "Journal Date"
                            applyFilter(option: filterOption)
                        }) {
                            Label("Journal Date", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease")
                            .font(.title)
                            .foregroundColor(.purple)
                            .padding(12)
                            .background(Circle().fill(Color.gray.opacity(0.4)))
                    }
                    
                    // Add New Journal Button
                    Button(action: {
                        showNewJournalSheet.toggle() // Toggle the sheet visibility
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purple)
                            .font(.title)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.4)))
                    }
                }
            }
            .padding()
            .background(Color.black)
            
            // Search Bar with Icons
            HStack {
                TextField("  Search...", text: $searchText)
                    .padding(.vertical, 9)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.horizontal, -10)
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: {
                                // Action for voice recorder (placeholder)
                                print("Voice recorder tapped")
                            }) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.gray)
                                    .padding(1)
                            }
                        }
                    )
            }
            .padding(.horizontal)
            
            Spacer()
            
            if filteredEntries.isEmpty {
                Image("book1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 77.7, height: 101)
                    .padding(140)
                
                Text("Begin Your Journal")
                    .bold()
                    .foregroundColor(.lavender)
                    .fontWeight(.heavy)
                    .font(.system(size: 25))
                
                Text("Craft your personal diary, \ntap the plus icon to begin")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .padding(10)
            }
            
            List {
                ForEach(filteredEntries) { entry in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(entry.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)

                            Spacer()
                            Button(action: {
                                if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
                                    journalEntries[index].isBookmarked.toggle()
                                }
                            }) {
                                Image(systemName: entry.isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 24))
                                    .foregroundColor(.purple)
                            }
                        }
                        Text(entry.creationDate, style: .date)
                            .font(.subheadline)
                        Text(entry.content)
                            .font(.body)
                    }
                    .swipeActions(edge: .leading) {
                        Button(action: {
                            onEdit(entry: entry)
                        }) {
                            Image(systemName: "pencil")
                        }
                        .tint(Color.purple)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            onDelete(entry: entry)
                        }) {
                            Image(systemName: "trash.fill")
                        }
                        .tint(Color.red)
                    }
                }
            }
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showNewJournalSheet) {
            NewJournalSheet(journalEntries: $journalEntries, entryToEdit: $entryToEdit)
        }
        .onAppear {
            loadEntries()
        }
    }
    
    // Function to handle filtering logic
    func applyFilter(option: String) {
        print("Filter applied: \(option)")
    }
    
    // Edit entry function
    func onEdit(entry: JournalEntry) {
        entryToEdit = entry
        showNewJournalSheet = true
    }
    
    // Delete entry function
    func onDelete(entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries.remove(at: index)
            saveEntries() // Save changes after deletion
        }
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
}

struct NewJournalSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var journalEntries: [JournalEntry]
    @Binding var entryToEdit: JournalEntry?
    @State private var journalTitle: String = ""
    @State private var journalContent: String = ""
    @State var isBookmarked: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.purple)
                
                Spacer()
                
                Button("Save") {
                    saveEntry()
                    dismiss()
                }
                .foregroundColor(.purple)
            }
            .padding(.horizontal)
           
            TextField("Title", text: $journalTitle)
                .font(.title)
                .padding(.top, 10)
                .foregroundColor(.white)
                .bold()
           
            Text(Date().formatted(.dateTime.day().month().year()))
                .foregroundColor(.gray)
                .padding(.trailing, 250)
                
            TextEditor(text: $journalContent)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            if let entry = entryToEdit {
                journalTitle = entry.title
                journalContent = entry.content
                isBookmarked = entry.isBookmarked
            }
        }
    }

    private func saveEntry() {
        guard !journalTitle.isEmpty && !journalContent.isEmpty else { return }

        if let index = journalEntries.firstIndex(where: { $0.id == entryToEdit?.id }) {
            journalEntries[index].title = journalTitle
            journalEntries[index].content = journalContent
            journalEntries[index].isBookmarked = isBookmarked
        } else {
            let newEntry = JournalEntry(title: journalTitle, content: journalContent, isBookmarked: isBookmarked)
            journalEntries.append(newEntry)
        }
        
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }
}
