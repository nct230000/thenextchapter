import Foundation
import Observation

struct CommunityEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let venue: String
    let distance: Double
    let languages: String
    let newcomers: Int
    let description: String

    static let potluck = CommunityEvent(
        id: "potluck", title: "A table for new beginnings", category: "FOOD & CULTURE",
        date: "SAT, OCT 24", time: "5–7 PM", venue: "Cedar Community Kitchen", distance: 2.1,
        languages: "Turkish & English", newcomers: 12,
        description: "Share a relaxed potluck, Turkish tea, and stories. Your host introduces the table, so you never have to break into a conversation.")
    static let coffee = CommunityEvent(
        id: "coffee", title: "Coffee, conversation & connection", category: "MEET & MINGLE",
        date: "SUN, OCT 25", time: "10–11:30 AM", venue: "Chapter House Café", distance: 1.4,
        languages: "English", newcomers: 10,
        description: "Small tables and friendly conversation prompts make it easy to meet others making Dallas home. All English levels welcome.")
    static let all = [potluck, coffee]
    static func find(_ id: String) -> CommunityEvent { all.first { $0.id == id } ?? potluck }
    var startTime: String { id == "potluck" ? "5:00 PM" : "10:00 AM" }
}

struct Preferences: Codable, Equatable {
    var culture = "No preference"
    var language = "Any language"
    var interest = "Choose interests"
    var nearby = "10 miles · Any price"
}

struct Outing: Identifiable, Codable, Equatable {
    var id = UUID()
    var eventID = "potluck"
    var name = ""
    var people: Set<String> = []
    var meetingPoint = ""
    var meetingTime = ""
    var transport = ""
    var note = ""
    var visibility = "Invite-only"
    var reminder = "1 day before"
    var event: CommunityEvent { CommunityEvent.find(eventID) }
    var isComplete: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !meetingPoint.isEmpty && !meetingTime.isEmpty && !transport.isEmpty && !note.isEmpty
    }
}

struct DemoState: Codable {
    var saved: Set<String> = []
    var joined: Set<String> = []
    var reminders: [String: String] = [:]
    var preferences = Preferences()
    var outings: [Outing] = []
}

@Observable final class AppStore {
    var selectedTab: AppTab = .discover
    private(set) var state: DemoState
    private let defaults: UserDefaults
    private let key = "NextChapter.demo.v1"

    init(defaults: UserDefaults = .standard, reset: Bool = false) {
        self.defaults = defaults
        if reset { defaults.removeObject(forKey: key) }
        if let data = defaults.data(forKey: key), let decoded = try? JSONDecoder().decode(DemoState.self, from: data) {
            state = decoded
        } else { state = DemoState() }
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(state) { defaults.set(data, forKey: key) }
    }
    func toggleSaved(_ id: String) {
        if state.saved.contains(id) { state.saved.remove(id) } else { state.saved.insert(id) }
        persist()
    }
    func toggleJoined(_ id: String) {
        if state.joined.contains(id) { state.joined.remove(id) } else { state.joined.insert(id) }
        persist()
    }
    func setReminder(_ value: String, for id: String) { state.reminders[id] = value; persist() }
    func setPreferences(_ value: Preferences) { state.preferences = value; persist() }
    @discardableResult func saveOuting(_ outing: Outing) -> Bool {
        guard outing.isComplete else { return false }
        if let index = state.outings.firstIndex(where: { $0.id == outing.id }) {
            state.outings[index] = outing
        } else { state.outings.append(outing) }
        persist()
        return true
    }
    func cancelOuting(_ id: UUID) { state.outings.removeAll { $0.id == id }; persist() }
    func reset() { state = DemoState(); persist() }
}

enum AppTab: String, CaseIterable { case discover = "Discover", saved = "Saved", plans = "Plans", profile = "Profile"
    var glyph: String { switch self { case .discover: "◈"; case .saved: "♡"; case .plans: "▦"; case .profile: "○" } }
}
enum EventFilter: String, CaseIterable, Identifiable {
    case all = "All nearby events", free = "Free & indoors this weekend", food = "Food & culture"
    var id: Self { self }
    var subtitle: String { switch self { case .all: "Clear the filters"; case .free: "Two welcoming events near Richardson"; case .food: "Discover a shared table" } }
    var events: [CommunityEvent] { self == .food ? [.potluck] : CommunityEvent.all }
}
enum PreferenceField: String, Identifiable {
    case culture, language, interest, nearby
    var id: Self { self }
    var title: String { switch self { case .culture: "A connection to culture."; case .language: "A language you enjoy."; case .interest: "What brings you joy?"; case .nearby: "Your kind of nearby." } }
    var eyebrow: String { switch self { case .culture: "FEEL A LITTLE AT HOME"; case .language: "YOUR COMFORT"; case .interest: "FIND COMMON GROUND"; case .nearby: "MAKE IT MANAGEABLE" } }
    var subtitle: String { switch self { case .culture: "Choose a culture you’d enjoy exploring. This is always optional."; case .language: "Language helps you know what to expect before you arrive."; case .interest: "Choose a starting point for your recommendations."; case .nearby: "Choose a travel range and budget that work for you." } }
    var choices: [String] { switch self { case .culture: ["Turkish", "No preference"]; case .language: ["Turkish", "English", "Any language"]; case .interest: ["Food", "Coffee", "Choose interests"]; case .nearby: ["5 miles · Free only", "10 miles · Any price"] } }
}
