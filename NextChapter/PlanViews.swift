import SwiftUI

enum PlannerStep: Int, CaseIterable {
    case event = 1, name, company, meeting, transport, note, settings, review, confirmed
    var title: String {
        switch self {
        case .event: "Start with an experience."
        case .name: "Give your plan a name."
        case .company: "The first hello, together."
        case .meeting: "Make meeting easy."
        case .transport: "A comfortable journey."
        case .note: "Set a welcoming tone."
        case .settings: "Keep everyone in the loop."
        case .review: "A plan to look forward to."
        case .confirmed: "Your outing is ready."
        }
    }
    var subtitle: String {
        switch self {
        case .event: "Choose an event your group can enjoy together."
        case .name: "A familiar name makes it easy for your group to recognize."
        case .company: "Invite Maya and Emre to this first gathering. Tap again to undo a choice."
        case .meeting: "Agree on a clear place and time before the event begins."
        case .transport: "Choose how your group plans to get there."
        case .note: "A few words can make arriving feel less daunting."
        case .settings: "Choose who can see the plan and when to get a reminder."
        case .review: ""
        case .confirmed: "The first step is a little easier together."
        }
    }
    var eyebrow: String {
        if self == .review { return "ONE LAST LOOK" }
        if self == .confirmed { return "YOUR NEXT CHAPTER STARTS HERE" }
        return "OUTING · \(rawValue) OF 7"
    }
}

struct PlansView: View {
    @Environment(AppStore.self) private var store
    @State private var draft: Outing?
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "BETTER TOGETHER", title: "Your next plans.", subtitle: "Turn “maybe” into a first hello.")
            ForEach(store.state.outings) { outing in
                NavigationLink { OutingDetailView(id: outing.id) } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OUTING READY · INVITATIONS PENDING").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
                        Text(outing.name).font(ChapterTheme.heading)
                    }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                        .background(ChapterTheme.soft, in: RoundedRectangle(cornerRadius: 12))
                }.buttonStyle(.plain)
            }
            Button("+ Plan an outing") { draft = Outing() }.buttonStyle(ChapterButtonStyle(primary: true))
            InfoCard(title: "A small plan. A shared start.", detail: "Pick an event, invite newcomers, and agree on where to meet.")
            Text("Bring your plans together, from the first hello to the meet-up.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        }.sheet(item: $draft) { OutingPlanner(initial: $0) }
    }
}

struct OutingPlanner: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Outing
    @State private var step: PlannerStep
    @State private var reviewed = false
    @State private var discard = false
    let editing: Bool
    init(initial: Outing, editing: Bool = false) {
        _draft = State(initialValue: initial)
        _step = State(initialValue: editing ? .name : .event)
        self.editing = editing
    }
    private var canContinue: Bool {
        switch step {
        case .name: return !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .meeting: return !draft.meetingPoint.isEmpty && !draft.meetingTime.isEmpty
        case .transport: return !draft.transport.isEmpty
        case .note: return !draft.note.isEmpty
        case .review: return reviewed && draft.isComplete
        default: return true
        }
    }
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ChapterPage {
                    Color.clear.frame(height: 0).id("top")
                    PageHeading(eyebrow: step.eyebrow, title: step.title, subtitle: step.subtitle.isEmpty ? nil : step.subtitle)
                    stepContent
                    if step.rawValue < PlannerStep.review.rawValue {
                        Button(step == .settings ? "Review outing →" : "Continue →") { advance() }
                            .buttonStyle(ChapterButtonStyle(primary: true)).disabled(!canContinue).accessibilityIdentifier("planner-continue")
                    } else if step == .review {
                        Button(editing ? "Save changes" : "Confirm outing") {
                            if store.saveOuting(draft) { step = .confirmed }
                        }.buttonStyle(ChapterButtonStyle(primary: true)).disabled(!canContinue).accessibilityIdentifier("confirm-outing")
                        Text("Invitations have not been sent.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
                    }
                    if step.rawValue > 1 && step != .confirmed {
                        Button("← Back") { reviewed = false; step = PlannerStep(rawValue: step.rawValue - 1) ?? .event }
                            .buttonStyle(ChapterButtonStyle(quiet: true))
                    }
                }.onChange(of: step) { _, _ in proxy.scrollTo("top", anchor: .top) }
            }
            .navigationTitle(editing ? "Edit outing" : "Plan an outing").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(step == .confirmed ? "Done" : "Cancel") { if step == .confirmed { dismiss() } else { discard = true } } }
            }
            .confirmationDialog("Discard your unsaved changes?", isPresented: $discard, titleVisibility: .visible) {
                Button("Discard changes", role: .destructive) { dismiss() }
                Button("Keep planning", role: .cancel) { }
            }
        }.tint(ChapterTheme.green).interactiveDismissDisabled(step != .confirmed)
    }
    @ViewBuilder private var stepContent: some View {
        switch step {
        case .event:
            ForEach(CommunityEvent.all) { event in
                Button {
                    if draft.eventID != event.id { draft.meetingTime = "" }
                    draft.eventID = event.id
                } label: {
                    ChoiceCard(title: event.title, detail: "\(event.date) · \(event.startTime) · Free", selected: draft.eventID == event.id)
                }.buttonStyle(.plain)
            }
        case .name:
            InfoCard(title: "Your shared experience", detail: "\(draft.event.title)\n\(draft.event.date) · \(draft.event.time)")
            VStack(alignment: .leading, spacing: 8) {
                Text("Outing name").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
                TextField("Choose an outing name", text: $draft.name).font(ChapterTheme.label)
                    .submitLabel(.next).onSubmit { if canContinue { advance() } }.accessibilityIdentifier("outing-name")
            }.padding(14).background(ChapterTheme.card, in: RoundedRectangle(cornerRadius: 12))
            Button { draft.name = draft.eventID == "potluck" ? "Our first Dallas potluck" : "Our first Dallas coffee" } label: {
                ChoiceCard(title: draft.eventID == "potluck" ? "Our first Dallas potluck" : "Our first Dallas coffee", detail: "Use this name")
            }.buttonStyle(.plain)
        case .company:
            person("Maya R.", detail: "New to Dallas · Coffee & art · English")
            person("Emre K.", detail: "New to Richardson · Food & music\nTurkish & English")
            InfoCard(title: "You decide who joins", detail: "Choose the people you’d like to meet. Everyone here is open to making new connections.")
        case .meeting:
            Button { draft.meetingPoint = "At the venue entrance" } label: {
                ChoiceCard(title: "At the venue entrance", detail: "Meeting point", selected: !draft.meetingPoint.isEmpty)
            }.buttonStyle(.plain)
            let time = draft.eventID == "potluck" ? "4:45 PM" : "9:45 AM"
            Button { draft.meetingTime = time } label: {
                ChoiceCard(title: time, detail: "Meet-up time · Dallas local time", selected: draft.meetingTime == time)
            }.buttonStyle(.plain)
            InfoCard(title: "Event starts at \(draft.event.startTime)", detail: "All times are Dallas local time. Give yourselves a little time to say hello.")
        case .transport:
            ForEach(["Public transit", "Walk", "Car"], id: \.self) { option in
                Button { draft.transport = option } label: {
                    ChoiceCard(title: option, detail: transportDetail(option), selected: draft.transport == option)
                }.buttonStyle(.plain)
            }
            Text("Travel times are estimates. Check your route before leaving.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        case .note:
            Button { draft.note = "Looking forward to meeting everyone!" } label: {
                ChoiceCard(title: "Looking forward to meeting everyone!", detail: "Welcome note", selected: !draft.note.isEmpty)
            }.buttonStyle(.plain)
            InfoCard(title: "A low-pressure first gathering", detail: "There is no pressure to share your background or speak before you feel ready.")
        case .settings:
            FieldCard(label: "Who can see this plan?", value: draft.visibility)
            Menu {
                ForEach(["1 day before", "2 hours before", "30 minutes before", "Off"], id: \.self) { value in
                    Button(value) { draft.reminder = value }
                }
            } label: { FieldCard(label: "Group reminder", value: draft.reminder) }
            InfoCard(title: "No surprises", detail: "Your group, your choice. Keep your plan invite-only and share only what you’re comfortable sharing.")
        case .review:
            OutingSummary(outing: draft)
            Toggle("I have checked the details", isOn: $reviewed).font(ChapterTheme.label).padding(14)
                .background(ChapterTheme.card, in: RoundedRectangle(cornerRadius: 12)).accessibilityIdentifier("review-details")
        case .confirmed:
            InfoCard(title: "✓  \(draft.name)", detail: "Plan ready · Invitations not sent")
            NavigationLink { OutingDetailView(id: draft.id) } label: { Text("View the plan") }.buttonStyle(ChapterButtonStyle(primary: true))
            Button("Back to my plans") { store.selectedTab = .plans; dismiss() }.buttonStyle(ChapterButtonStyle())
            InfoCard(title: "What happens next?", detail: "Review your meeting point and travel details before you go. Invitations have not been sent.")
        }
    }
    private func advance() { if canContinue { step = PlannerStep(rawValue: step.rawValue + 1) ?? .review } }
    private func person(_ name: String, detail: String) -> some View {
        Button { if draft.people.contains(name) { draft.people.remove(name) } else { draft.people.insert(name) } } label: {
            ChoiceCard(title: name, detail: detail, selected: draft.people.contains(name))
        }.buttonStyle(.plain)
    }
    private func transportDetail(_ option: String) -> String {
        switch option {
        case "Public transit": return draft.eventID == "potluck" ? "Route 883 + 7-minute walk\n25 minutes · Estimated $3 fare" : "Check your route before leaving."
        case "Walk": return "Check a real route and allow extra time."
        default: return "Arrange a ride and confirm parking."
        }
    }
}

struct OutingSummary: View {
    let outing: Outing
    var body: some View {
        InfoCard(title: outing.event.title, detail: "\(outing.event.date) · \(outing.event.time)\n\(outing.event.venue) · Free")
        Text("Your outing").font(ChapterTheme.heading)
        DetailRow(label: "Name", value: outing.name)
        DetailRow(label: "Meet-up location", value: outing.meetingPoint)
        DetailRow(label: "Meet-up time", value: outing.meetingTime)
        DetailRow(label: "Transport", value: outing.transport)
        DetailRow(label: "Welcome note", value: outing.note)
        DetailRow(label: "Visibility", value: outing.visibility)
        DetailRow(label: "Reminder", value: outing.reminder)
        DetailRow(label: "Your group · invitations pending", value: outing.people.isEmpty ? "Just you for now" : outing.people.sorted().joined(separator: "\n"))
    }
}

struct OutingDetailView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let id: UUID
    @State private var draft: Outing?
    @State private var cancel = false
    var body: some View {
        ChapterPage {
            if let outing = store.state.outings.first(where: { $0.id == id }) {
                PageHeading(eyebrow: "YOUR SHARED OUTING", title: "A first hello, planned.")
                OutingSummary(outing: outing)
                NavigationLink { CalendarPreview(outing: outing) } label: { Text("Add to calendar") }.buttonStyle(ChapterButtonStyle())
                Button("Edit arrangements") { draft = outing }.buttonStyle(ChapterButtonStyle())
                Button("Cancel outing") { cancel = true }.buttonStyle(ChapterButtonStyle(quiet: true))
                Text("Your plan is ready to review. Invitations have not been sent.").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
            }
        }.navigationTitle("Your outing")
            .sheet(item: $draft) { OutingPlanner(initial: $0, editing: true) }
            .confirmationDialog("Cancel this outing?", isPresented: $cancel, titleVisibility: .visible) {
                Button("Cancel outing", role: .destructive) { store.cancelOuting(id); dismiss() }
                Button("Keep outing", role: .cancel) { }
            }
    }
}

struct CalendarPreview: View {
    let outing: Outing
    var body: some View {
        ChapterPage {
            PageHeading(eyebrow: "CALENDAR PREVIEW", title: "A date for your next chapter.", subtitle: "Check the event details before adding them to your calendar.")
            InfoCard(title: outing.event.date, detail: "\(outing.event.title)\n\(outing.event.time) · \(outing.event.venue)\nCalendar entry not added yet.")
        }.navigationTitle("Calendar preview")
    }
}
