import SwiftUI

struct DiscoverView: View {
    @Binding var selectedTab: AppTab
    @State private var filters = DiscoveryFilters()
    @State private var showFilters = false
    var body: some View {
        let results = filters.results(in: CommunityEvent.all)
        ChapterPage {
            NavigationLink { FilterView() } label: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A NEW CITY. YOUR PEOPLE.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.lime)
                    Text("Your next\nconnection starts\nhere.").font(ChapterTheme.title).lineSpacing(3)
                        .foregroundStyle(ChapterTheme.card).fixedSize(horizontal: false, vertical: true)
                    Text("Find a familiar feeling, somewhere new.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.lime)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(22)
                    .background(ChapterTheme.green, in: RoundedRectangle(cornerRadius: 12))
            }.buttonStyle(.plain)
            NavigationLink { FilterView() } label: {
                FieldCard(label: "Discover near Richardson", value: "Browse welcoming events")
            }.buttonStyle(.plain)
            TextField("Search events", text: $filters.search)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
            ViewThatFits(in: .horizontal) {
                HStack { sizeMenu; filterButton }
                VStack(alignment: .leading) { sizeMenu; filterButton }
            }
            if results.isEmpty {
                InfoCard(title: "No events found", detail: "Try a different search or clear your filters.")
            }
            ForEach(results) { event in
                NavigationLink { EventDetailView(event: event) } label: {
                    EventCard(event: event, compact: event.id != "potluck")
                }.buttonStyle(.plain).accessibilityIdentifier("event-\(event.id)")
            }
            Button("Make this feel like you") { selectedTab = .profile }.buttonStyle(ChapterButtonStyle())
        }.sheet(isPresented: $showFilters) { DiscoveryFilterSheet(filters: $filters) }
    }

    private var sizeMenu: some View {
        Menu {
            Picker("Event size", selection: $filters.size) {
                Text("Any size").tag(nil as EventSize?)
                ForEach(EventSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(Optional(size))
                }
            }
        } label: {
            Label(filters.size?.rawValue ?? "Event Size", systemImage: "chevron.down")
                .padding(12).background(ChapterTheme.card, in: Capsule())
        }
        .accessibilityLabel("Event size")
        .accessibilityValue(filters.size?.rawValue ?? "Any size")
    }

    private var filterButton: some View {
        Button { showFilters = true } label: {
            Label("Filters & sort", systemImage: "line.3.horizontal.decrease")
                .padding(12).background(ChapterTheme.card, in: Capsule())
        }
    }
}

private struct DiscoveryFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: DiscoveryFilters
    private let events = CommunityEvent.all

    var body: some View {
        NavigationStack {
            Form {
                Section("Events") {
                    options("Age range", values: events.map(\.ageGroup), selection: $filters.ageGroup)
                    options("Category", values: events.map(\.category), selection: $filters.category)
                    options("Tag", values: events.flatMap(\.tags), selection: $filters.tag)
                    Picker("Distance", selection: $filters.maximumDistance) {
                        Text("Any distance").tag(nil as Int?)
                        ForEach([5, 10, 15, 20], id: \.self) { miles in
                            Text("\(miles) miles").tag(Optional(miles))
                        }
                    }
                    Picker("Price", selection: $filters.maximumPrice) {
                        Text("Any price").tag(nil as Int?)
                        Text("Free only").tag(Optional(0))
                        ForEach([10, 20, 50], id: \.self) { price in
                            Text("Up to $\(price)").tag(Optional(price))
                        }
                    }
                }
                Section("Availability") {
                    let firstDate = CommunityEvent.potluck.eventDate
                    Toggle("Filter by date", isOn: enabled($filters.date, defaultDate: firstDate))
                    if let date = Binding($filters.date) {
                        DatePicker("Event date", selection: date, displayedComponents: .date)
                    }
                    Toggle("Filter by start time", isOn: enabled($filters.time, defaultDate: firstDate))
                    if let time = Binding($filters.time) {
                        Picker("Starts", selection: $filters.timeRule) {
                            ForEach(DiscoveryFilters.TimeRule.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                    }
                }
                Picker("Sort by", selection: $filters.sort) {
                    ForEach(DiscoveryFilters.Sort.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Button("Clear filters") {
                    filters = DiscoveryFilters(search: filters.search)
                }
            }
            .navigationTitle("Filters & sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private func options(_ title: String, values: [String], selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            Text("Any").tag("")
            ForEach(Set(values).sorted(), id: \.self) { Text($0).tag($0) }
        }
    }

    private func enabled(_ value: Binding<Date?>, defaultDate: Date) -> Binding<Bool> {
        Binding(get: { value.wrappedValue != nil }, set: { value.wrappedValue = $0 ? defaultDate : nil })
    }
}

struct FilterView: View {
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "FIND YOUR KIND OF EVENT", title: "A little closer to you.")
            ForEach([EventFilter.free, .food, .all]) { filter in
                NavigationLink { EventResultsView(filter: filter) } label: {
                    ChoiceCard(title: filter.rawValue, detail: filter.subtitle)
                }.buttonStyle(.plain)
            }
        }.navigationTitle("Discover")
    }
}

struct EventResultsView: View {
    var filter: EventFilter = .all
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: filter == .free ? "FREE · INDOORS · THIS WEEKEND" : filter.rawValue.uppercased(), title: "A comfortable place to start.")
            ForEach(filter.events) { event in
                NavigationLink { EventDetailView(event: event) } label: { EventCard(event: event) }.buttonStyle(.plain)
            }
        }.navigationTitle("Events")
    }
}

struct EventDetailView: View {
    @Environment(AppStore.self) private var store
    let event: CommunityEvent
    @State private var planning = false
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: event.category.uppercased(), title: event.title + ".")
            if event.id == "potluck" {
                Image("EventArtwork").resizable().aspectRatio(342.0 / 92.0, contentMode: .fit)
                    .accessibilityHidden(true)
            }
            Text("\(event.date) · \(event.time) · \(event.priceLabel.uppercased())")
                .font(ChapterTheme.small).foregroundStyle(ChapterTheme.orange)
            Text("\(event.venue) · Richardson").font(ChapterTheme.label)
            Text(event.description).lineSpacing(3)
            InfoCard(title: event.id == "potluck" ? "A little taste of home" : "Know before you go",
                     detail: "\(event.languages) · \(event.newcomers) newcomers\n\(event.arrivalInfo)")
            Button(store.state.saved.contains(event.id) ? "♥ Saved · Tap to remove" : "♡ Save event") { store.toggleSaved(event.id) }
                .buttonStyle(ChapterButtonStyle()).accessibilityIdentifier("save-event")
            Button(store.state.joined.contains(event.id) ? "✓ Joined · Tap to leave" : "Join event") { store.toggleJoined(event.id) }
                .buttonStyle(ChapterButtonStyle(primary: true)).accessibilityIdentifier("join-event")
            Button("Plan to go together") { planning = true }.buttonStyle(ChapterButtonStyle())
            NavigationLink { AttendeesView(event: event) } label: { Text("See people attending") }.buttonStyle(ChapterButtonStyle(quiet: true))
            Text("Preview listing · No reservation has been made.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        }.navigationTitle("Event details")
            .sheet(isPresented: $planning) { OutingPlanner(initial: Outing(eventID: event.id)) }
    }
}

struct SavedView: View {
    @Environment(AppStore.self) private var store
    @Binding var selectedTab: AppTab
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "YOUR SHORTLIST", title: "A little possibility.", subtitle: "Keep the events you want to come back to.")
            if store.state.saved.isEmpty {
                InfoCard(title: "Your next possibility is out there.", detail: "Use the heart on an event to save it here.")
            }
            ForEach(CommunityEvent.all.filter { store.state.saved.contains($0.id) }) { event in
                NavigationLink { EventDetailView(event: event) } label: { EventCard(event: event) }.buttonStyle(.plain)
                NavigationLink { ReminderView(event: event) } label: {
                    FieldCard(label: "Event reminder", value: store.state.reminders[event.id] ?? "Off")
                }.buttonStyle(.plain)
            }
            Text("Use the heart on an event to add or remove it here.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
            Button("Discover more events") { selectedTab = .discover }.buttonStyle(ChapterButtonStyle(primary: true))
        }
    }
}

struct ReminderView: View {
    @Environment(AppStore.self) private var store
    let event: CommunityEvent
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "SAVED EVENT", title: "A nudge for later.", subtitle: "Choose when to remind yourself about the event.")
            ForEach(["1 day before", "2 hours before", "30 minutes before", "Off"], id: \.self) { option in
                Button { store.setReminder(option, for: event.id) } label: {
                    ChoiceCard(title: option, selected: (store.state.reminders[event.id] ?? "Off") == option)
                }.buttonStyle(.plain)
            }
            InfoCard(title: "Your reminder preference", detail: "Reminders aren’t active yet. No notifications are sent.")
        }.navigationTitle("Reminder")
    }
}

struct AttendeesView: View {
    let event: CommunityEvent
    @State private var planning = false
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "A WELCOMING ROOM", title: "People making a new start.", subtitle: event.id == "potluck" ? "18 people going, including \(event.newcomers) newcomers." : "\(event.newcomers) newcomers going.")
            if event.id == "potluck" { InfoCard(title: "Deniz · Your host", detail: "Speaks Turkish & English\nIntroduces first-time attendees.") }
            ChoiceCard(title: "Maya R.", detail: "New to Dallas · Coffee & art")
            ChoiceCard(title: "Emre K.", detail: "New to Richardson · Food & music")
            ChoiceCard(title: "Priya S.", detail: "New to Plano · Music & cooking")
            Button("Plan to go together") { planning = true }.buttonStyle(ChapterButtonStyle(primary: true))
            Text("Meet at your own pace. Your comfort comes first.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        }.navigationTitle("People attending")
            .sheet(isPresented: $planning) { OutingPlanner(initial: Outing(eventID: event.id)) }
    }
}
