import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @Binding var selectedTab: AppTab
    let goToDiscoverHome: () -> Void
    @State private var editor: PreferenceField?
    @State private var showMatches = false
    @State private var showSuccess = false
    @State private var openMatchesAfterConfirmation = false
    @State private var resetConfirmation = false
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "YOUR PREFERENCES", title: "Make room for\nwhat matters.", subtitle: "Cultural background is optional. Every event welcomes every background.")
            preference(.culture, label: "Cultural connection", value: store.state.preferences.culture)
            preference(.language, label: "Event language", value: store.state.preferences.language)
            preference(.interest, label: "Interests", value: store.state.preferences.interest)
            preference(.distance, label: "Distance", value: store.state.preferences.distance)
            preference(.budget, label: "Budget", value: store.state.preferences.budget)
            Button("Save Profile") { showSuccess = true }.buttonStyle(ChapterButtonStyle(primary: true))
            NavigationLink { AboutView(selectedTab: $selectedTab) } label: { Text("About The Next Chapter") }.buttonStyle(ChapterButtonStyle(quiet: true))
            Button("Reset demo") { resetConfirmation = true }.font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted).frame(maxWidth: .infinity, minHeight: 44)
        }
        .sheet(item: $editor) { field in PreferenceEditor(field: field) }
        .navigationDestination(isPresented: $showMatches) { MatchesView() }
        .fullScreenCover(isPresented: $showSuccess, onDismiss: {
            if openMatchesAfterConfirmation {
                openMatchesAfterConfirmation = false
                showMatches = true
            }
        }) {
            ProfileSuccessConfirmation(
                seeMatches: {
                    openMatchesAfterConfirmation = true
                    showSuccess = false
                },
                backToProfile: { showSuccess = false }
            )
            .presentationBackground(.clear)
        }
        .confirmationDialog("Ready for a new chapter?", isPresented: $resetConfirmation, titleVisibility: .visible) {
            Button("Reset demo", role: .destructive) {
                store.reset()
                goToDiscoverHome()
            }
            Button("Keep my progress", role: .cancel) { }
        } message: { Text("This clears saved events, preferences and outing plans on this device.") }
    }
    private func preference(_ field: PreferenceField, label: String, value: String) -> some View {
        Button { editor = field } label: { FieldCard(label: label, value: value) }.buttonStyle(.plain)
    }
}

private struct ProfileSuccessConfirmation: View {
    let seeMatches: () -> Void
    let backToProfile: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().accessibilityHidden(true)

            ViewThatFits(in: .vertical) {
                confirmationCard
                ScrollView { confirmationCard.frame(maxWidth: .infinity) }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAction(.escape) { backToProfile() }
    }

    private var confirmationCard: some View {
        VStack(spacing: 72) {
            Text("Profile\nCreation\nSuccessful!")
                .font(ChapterTheme.title)
                .foregroundStyle(ChapterTheme.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Profile Creation Successful!")
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 7) {
                Button("See Matches", action: seeMatches)
                    .buttonStyle(ChapterButtonStyle(primary: true))
                Button("Back to Profile", action: backToProfile)
                    .buttonStyle(ChapterButtonStyle())
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 74)
        .padding(.bottom, 22)
        .frame(maxWidth: 300)
        .background(ChapterTheme.cream, in: RoundedRectangle(cornerRadius: 12))
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
                ForEach(choices, id: \.self) { choice in
                    Button { select(choice); dismiss() } label: { ChoiceCard(title: choice, selected: current == choice) }.buttonStyle(.plain)
                }
            }.toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }.tint(ChapterTheme.green).presentationDragIndicator(.visible)
    }
    private var current: String {
        store.state.preferences[keyPath: field.value]
    }
    private var choices: [String] {
        field.choices.contains(current) ? field.choices : [current] + field.choices
    }
    private func select(_ choice: String) {
        var p = store.state.preferences
        p[keyPath: field.value] = choice
        store.setPreferences(p)
    }
}

struct MatchesView: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        let preferences = store.state.preferences
        ChapterPage {
            PageHeading(eyebrow: "YOUR NEXT CHAPTER", title: "A few familiar feelings.", subtitle: "Your preferences are saved. Explore a welcoming starting point.")
            InfoCard(title: "Your selected preferences", detail: "\(preferences.culture) · \(preferences.language)\n\(preferences.interest) · \(preferences.distance) · \(preferences.budget)")
            if preferences.matches.isEmpty {
                InfoCard(title: "No matches yet", detail: "Try changing your preferences to see more events.")
            }
            ForEach(preferences.matches) { event in
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
