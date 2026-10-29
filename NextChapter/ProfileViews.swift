import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @Binding var selectedTab: AppTab
    @State private var editor: PreferenceField?
    @State private var showMatches = false
    @State private var resetConfirmation = false
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "YOUR PREFERENCES", title: "Make room for\nwhat matters.", subtitle: "Cultural background is optional. Every event welcomes every background.")
            preference(.culture, label: "Cultural connection", value: store.state.preferences.culture)
            preference(.language, label: "Event language", value: store.state.preferences.language)
            preference(.interest, label: "Interests", value: store.state.preferences.interest)
            preference(.nearby, label: "Distance & budget", value: store.state.preferences.nearby)
            Button("Save & see my matches") { showMatches = true }.buttonStyle(ChapterButtonStyle(primary: true))
            NavigationLink { AboutView(selectedTab: $selectedTab) } label: { Text("About The Next Chapter") }.buttonStyle(ChapterButtonStyle(quiet: true))
            Button("Reset demo") { resetConfirmation = true }.font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted).frame(maxWidth: .infinity, minHeight: 44)
        }
        .sheet(item: $editor) { field in PreferenceEditor(field: field) }
        .navigationDestination(isPresented: $showMatches) { MatchesView() }
        .confirmationDialog("Ready for a new chapter?", isPresented: $resetConfirmation, titleVisibility: .visible) {
            Button("Reset demo", role: .destructive) { store.reset(); selectedTab = .discover }
            Button("Keep my progress", role: .cancel) { }
        } message: { Text("This clears saved events, preferences and outing plans on this device.") }
    }
    private func preference(_ field: PreferenceField, label: String, value: String) -> some View {
        Button { editor = field } label: { FieldCard(label: label, value: value) }.buttonStyle(.plain)
    }
}

struct PreferenceEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let field: PreferenceField
    var body: some View {
        NavigationStack {
            ChapterPage {
                PageHeading(eyebrow: field.eyebrow, title: field.title, subtitle: field.subtitle)
                ForEach(field.choices, id: \.self) { choice in
                    Button { select(choice); dismiss() } label: { ChoiceCard(title: choice, selected: current == choice) }.buttonStyle(.plain)
                }
                if field == .nearby { InfoCard(title: "Start small", detail: "A nearby, free event can make the first step feel easier.") }
            }.toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }.tint(ChapterTheme.green).presentationDragIndicator(.visible)
    }
    private var current: String {
        let p = store.state.preferences
        switch field { case .culture: return p.culture; case .language: return p.language; case .interest: return p.interest; case .nearby: return p.nearby }
    }
    private func select(_ choice: String) {
        var p = store.state.preferences
        switch field { case .culture: p.culture = choice; case .language: p.language = choice; case .interest: p.interest = choice; case .nearby: p.nearby = choice }
        store.setPreferences(p)
    }
}

struct MatchesView: View {
    @Environment(AppStore.self) private var store
    private var matches: [CommunityEvent] {
        let p = store.state.preferences
        if p.interest == "Food" || p.language == "Turkish" || p.culture == "Turkish" { return [.potluck] }
        if p.interest == "Coffee" { return [.coffee] }
        return CommunityEvent.all
    }
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "YOUR NEXT CHAPTER", title: "A few familiar feelings.", subtitle: "Your preferences are saved. Explore a welcoming starting point.")
            InfoCard(title: "Your selected preferences", detail: "\(store.state.preferences.culture) · \(store.state.preferences.language)\n\(store.state.preferences.interest) · \(store.state.preferences.nearby)")
            ForEach(matches) { event in
                NavigationLink { EventDetailView(event: event) } label: { EventCard(event: event) }.buttonStyle(.plain)
            }
            Text("Picked for your interests and your neighborhood.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        }.navigationTitle("Your matches")
    }
}

struct AboutView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "THE NEXT CHAPTER", title: "Find your people. Feel at home.", subtitle: "Discover welcoming places, familiar cultures, and new connections in your city.")
            InfoCard(title: "Your next chapter starts here", detail: "Find an event that feels like you, save it for later, and make a plan to go together.")
            InfoCard(title: "Your comfort comes first", detail: "Choose the interests, languages, and cultural connections that matter to you. Share as much or as little as you like.")
            InfoCard(title: "Start with one hello", detail: "A shared table, a friendly conversation, or a familiar language can be the beginning of something good.")
            Button("Personalize my recommendations") { dismiss() }.buttonStyle(ChapterButtonStyle(primary: true))
            Button("Back to Discover") { selectedTab = .discover; dismiss() }.buttonStyle(ChapterButtonStyle())
        }.navigationTitle("About")
    }
}
