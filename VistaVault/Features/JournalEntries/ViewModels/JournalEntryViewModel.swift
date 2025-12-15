import Combine
import Foundation

@MainActor
class JournalEntryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var journalEntries = [JournalEntry]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let journalEntryService = JournalEntryService.shared
    private let authManager = LocalAuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() { }
    
    // MARK: - Journal Entry Operations
    
    func createJournalEntry(_ entry: JournalEntry) async -> Result<Void, Error> {
        guard authManager.currentUserId != nil else {
            return .failure(NSError(domain: "Auth", code: 401))
        }
        
        do {
            try await journalEntryService.createJournalEntry(entry)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateJournalEntry(_ entry: JournalEntry) async -> Result<Void, Error> {
        do {
            try await journalEntryService.updateJournalEntry(entry)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteJournalEntry(id: String) async -> Result<Void, Error> {
        do {
            try await journalEntryService.deleteJournalEntry(id: id)
            await MainActor.run {
                journalEntries.removeAll { $0.id == id }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Fetching
    
    func fetchAllJournalEntries() {
        isLoading = true
        
        Task {
            do {
                let fetchedEntries = try await journalEntryService.fetchAllJournalEntries()
                await MainActor.run {
                    self.journalEntries = fetchedEntries
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Failed to fetch journal entries: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchJournalEntry(byId id: String) async -> JournalEntry? {
        do {
            return try await journalEntryService.fetchJournalEntry(byId: id)
        } catch {
            await MainActor.run {
                handleError("Failed to fetch journal entry: \(error.localizedDescription)")
            }
            return nil
        }
    }
    
    // MARK: - Filtering
    
    func filterEntries(startDate: Date, endDate: Date) {
        isLoading = true
        
        Task {
            do {
                let fetchedEntries = try await journalEntryService.fetchAllJournalEntries()
                let filtered = fetchedEntries.filter { entry in
                    entry.date >= startDate && entry.date <= endDate
                }
                
                await MainActor.run {
                    self.journalEntries = filtered
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Filter error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func generateEntryNumber() async throws -> String {
        try await journalEntryService.generateEntryNumber()
    }
    
    // MARK: - Helpers
    
    func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
}
