import Foundation
import Observation

enum EventSize: String, CaseIterable {
    case small = "Small group"
    case medium = "Medium group"
    case large = "Large group"
}

struct CommunityEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let day: Int
    let startMinute: Int
    let duration: Int
    let venue: String
    let distance: Double
    let commuteMinutes: Int?
    let price: Int
    let size: EventSize
    let ageGroup: String
    let tags: [String]
    let languages: String
    let newcomers: Int
    let description: String
    let arrivalInfo: String
    let suggestedOutingName: String

    static let potluck = CommunityEvent(
        id: "potluck", title: "A table for new beginnings", category: "Food & culture",
        day: 20261024, startMinute: 17 * 60, duration: 120,
        venue: "Cedar Community Kitchen", distance: 2.1, commuteMinutes: 15, price: 0,
        size: .medium, ageGroup: "All ages", tags: ["Indoors", "Step-free entrance", "Vegetarian options"],
        languages: "Turkish & English", newcomers: 12,
        description: "Share a relaxed potluck, Turkish tea, and stories. Your host introduces the table, so you never have to break into a conversation.",
        arrivalInfo: "Indoors · Step-free entrance · Vegetarian options", suggestedOutingName: "Our first Dallas potluck")
    static let coffee = CommunityEvent(
        id: "coffee", title: "Coffee, conversation & connection", category: "Meet & mingle",
        day: 20261025, startMinute: 10 * 60, duration: 90,
        venue: "Chapter House Café", distance: 1.4, commuteMinutes: 10, price: 0,
        size: .small, ageGroup: "Adults", tags: ["Indoors", "Conversation", "Coffee", "Newcomers"],
        languages: "English", newcomers: 10,
        description: "Small tables and friendly conversation prompts make it easy to meet others making Dallas home. All English levels welcome.",
        arrivalInfo: "Indoor seating · Drinks purchased separately", suggestedOutingName: "Our first Dallas coffee")
    static let bingo = CommunityEvent(
        id: "bingo", title: "Bingo & Board Games", category: "Games",
        day: 20261101, startMinute: 19 * 60, duration: 90,
        venue: "Diner Café", distance: 1.4, commuteMinutes: nil, price: 5,
        size: .small, ageGroup: "All ages", tags: ["Indoors", "Board games"],
        languages: "English", newcomers: 8,
        description: "Join a relaxed round of bingo or pull up a chair for a board game. You can learn the rules at the table.",
        arrivalInfo: "Indoor seating · Food and drinks purchased separately", suggestedOutingName: "Dallas game night")

    static let all = [potluck, coffee, bingo]
    static let calendar = Calendar(identifier: .gregorian)
    static func find(_ id: String) -> CommunityEvent { all.first { $0.id == id } ?? potluck }

    var eventDate: Date {
        calendarDate(year: day / 10000, month: day / 100 % 100, day: day % 100, minute: 12 * 60)
    }
    var date: String { eventDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased() }
    var startTime: String { formattedTime(startMinute) }
    var time: String { "\(startTime)–\(formattedTime(startMinute + duration))" }
    var meetingTime: String { formattedTime(startMinute - 15) }
    var priceLabel: String { price == 0 ? "Free" : "$\(price)" }
    private func formattedTime(_ minute: Int) -> String {
        calendarDate(year: 2000, month: 1, day: 1, minute: minute).formatted(.dateTime.hour().minute())
    }
    private func calendarDate(year: Int, month: Int, day: Int, minute: Int) -> Date {
        Self.calendar.date(from: DateComponents(year: year, month: month, day: day, hour: minute / 60, minute: minute % 60))!
    }
}

struct Preferences: Codable, Equatable {
    var culture = "No preference"
    var language = "Any language"
    var interest = "Choose interests"
    var distance = "10 miles"
    var budget = "Any price"

    private enum CodingKeys: String, CodingKey { case culture, language, interest, distance, budget, nearby }

    init() {}

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        culture = try values.decodeIfPresent(String.self, forKey: .culture) ?? culture
        language = try values.decodeIfPresent(String.self, forKey: .language) ?? language
        interest = try values.decodeIfPresent(String.self, forKey: .interest) ?? interest
        let legacy = try values.decodeIfPresent(String.self, forKey: .nearby)?.components(separatedBy: " · ") ?? []
        distance = try values.decodeIfPresent(String.self, forKey: .distance) ?? legacy.first ?? distance
        budget = try values.decodeIfPresent(String.self, forKey: .budget) ?? legacy.dropFirst().first ?? budget
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(culture, forKey: .culture)
        try values.encode(language, forKey: .language)
        try values.encode(interest, forKey: .interest)
        try values.encode(distance, forKey: .distance)
        try values.encode(budget, forKey: .budget)
    }

    var matches: [CommunityEvent] {
        let maximumDistance = Double(distance.split(separator: " ").first ?? "") ?? 10
        let maximumPrice = budget == "Free only" ? 0 : budget.split(separator: "$").dropFirst().first.flatMap { Int($0) }
        let nearbyEvents = CommunityEvent.all.filter { event in
            event.distance <= maximumDistance && (maximumPrice.map { event.price <= $0 } ?? true)
        }
        if interest == "Food" || language == "Turkish" || culture == "Turkish" { return nearbyEvents.filter { $0.id == "potluck" } }
        if interest == "Coffee" { return nearbyEvents.filter { $0.id == "coffee" } }
        return nearbyEvents
    }
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
    var events: [CommunityEvent] {
        switch self {
        case .all: CommunityEvent.all
        case .free: CommunityEvent.all.filter { (20261024...20261025).contains($0.day) && $0.price == 0 && $0.tags.contains("Indoors") }
        case .food: CommunityEvent.all.filter { $0.category == "Food & culture" }
        }
    }
}

struct DiscoveryFilters: Equatable {
    enum Sort: String, CaseIterable {
        case soonest = "Soonest first", distance = "Nearest first", price = "Lowest price first"
    }
    enum TimeRule: String, CaseIterable {
        case at = "At", before = "Before", after = "After"
    }

    var search = ""
    var size: EventSize?
    var ageGroup = ""
    var category = ""
    var tag = ""
    var maximumDistance: Int?
    var maximumPrice: Int?
    var date: Date?
    var time: Date?
    var timeRule = TimeRule.after
    var sort = Sort.soonest

    func results(in events: [CommunityEvent]) -> [CommunityEvent] {
        let calendar = CommunityEvent.calendar
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        let minute = time.map { calendar.component(.hour, from: $0) * 60 + calendar.component(.minute, from: $0) }
        return events.filter { event in
            let searchable = [event.title, event.venue, event.category] + event.tags
            return (query.isEmpty || searchable.contains { $0.localizedStandardContains(query) })
                && (size == nil || event.size == size)
                && (ageGroup.isEmpty || event.ageGroup == ageGroup)
                && (category.isEmpty || event.category == category)
                && (tag.isEmpty || event.tags.contains(tag))
                && (maximumDistance.map { event.distance <= Double($0) } ?? true)
                && (maximumPrice.map { event.price <= $0 } ?? true)
                && (date.map { calendar.isDate($0, inSameDayAs: event.eventDate) } ?? true)
                && (minute.map { matchesTime(event.startMinute, $0) } ?? true)
        }.sorted { first, second in
            if sort == .distance && first.distance != second.distance { return first.distance < second.distance }
            if sort == .price && first.price != second.price { return first.price < second.price }
            return (first.day, first.startMinute) < (second.day, second.startMinute)
        }
    }

    private func matchesTime(_ start: Int, _ minute: Int) -> Bool {
        switch timeRule {
        case .at: start == minute
        case .before: start < minute
        case .after: start > minute
        }
    }
}

enum PreferenceField: String, Identifiable {
    case culture, language, interest, distance, budget
    var id: Self { self }
    var value: WritableKeyPath<Preferences, String> {
        switch self {
        case .culture: \.culture
        case .language: \.language
        case .interest: \.interest
        case .distance: \.distance
        case .budget: \.budget
        }
    }
    var title: String { switch self { case .culture: "A connection to culture."; case .language: "A language you enjoy."; case .interest: "What brings you joy?"; case .distance: "Your kind of nearby."; case .budget: "What’s your budget?" } }
    var eyebrow: String { switch self { case .culture: "FEEL A LITTLE AT HOME"; case .language: "YOUR COMFORT"; case .interest: "FIND COMMON GROUND"; case .distance, .budget: "MAKE IT MANAGEABLE" } }
    var subtitle: String { switch self { case .culture: "Choose a culture you’d enjoy exploring. This is always optional."; case .language: "Language helps you know what to expect before you arrive."; case .interest: "Choose a starting point for your recommendations."; case .distance: "Choose a travel range that works for you."; case .budget: "Choose a budget that works for you." } }
    var choices: [String] {
        switch self {
        case .culture: ["Turkish", "No preference"]
        case .language: ["Turkish", "English", "Any language"]
        case .interest: ["Food", "Coffee", "Choose interests"]
        case .distance: ["10 miles", "15 miles", "20 miles"]
        case .budget: ["Free only", "Up to $10", "Up to $20", "Up to $50", "Any price"]
        }
    }
}
