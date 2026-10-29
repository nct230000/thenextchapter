import SwiftUI

enum ChapterTheme {
    static let cream = Color("Cream"), ink = Color("Ink"), green = Color("Green")
    static let muted = Color("Muted"), lime = Color("Lime"), soft = Color("Soft")
    static let orange = Color("Orange"), card = Color("Card")
    static let small = Font.custom("Inter-Regular", size: 11, relativeTo: .caption2)
    static let body = Font.custom("Inter-Regular", size: 14, relativeTo: .body)
    static let label = Font.custom("Inter-SemiBold", size: 14, relativeTo: .subheadline)
    static let heading = Font.custom("Inter-SemiBold", size: 18, relativeTo: .headline)
    static let title = Font.custom("DMSerifDisplay-Regular", size: 30, relativeTo: .largeTitle)
}

struct ChapterButtonStyle: ButtonStyle {
    var primary = false
    var quiet = false
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(ChapterTheme.label)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(primary ? ChapterTheme.card : ChapterTheme.ink)
            .background(primary ? ChapterTheme.green : (quiet ? ChapterTheme.cream : ChapterTheme.card), in: RoundedRectangle(cornerRadius: 12))
            .opacity(enabled ? (configuration.isPressed ? 0.72 : 1) : 0.4)
    }
}

struct ChapterPage<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) { content }
                .frame(maxWidth: 560, alignment: .leading).padding(24).frame(maxWidth: .infinity)
        }
        .background(ChapterTheme.cream)
        .foregroundStyle(ChapterTheme.ink).font(ChapterTheme.body)
    }
}

struct PageHeading: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    var body: some View {
        Text(eyebrow).font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
        Text(title).font(ChapterTheme.title).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
        if let subtitle { Text(subtitle).foregroundStyle(ChapterTheme.muted).fixedSize(horizontal: false, vertical: true) }
    }
}

struct InfoCard: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(ChapterTheme.label)
            Text(detail).font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted).lineSpacing(3)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(ChapterTheme.soft, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct FieldCard: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
            Text(value).font(ChapterTheme.label)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(ChapterTheme.card, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
    }
}

struct ChoiceCard: View {
    let title: String
    var detail = ""
    var selected = false
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(ChapterTheme.label)
                if !detail.isEmpty { Text(detail).font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted) }
            }
            Spacer(minLength: 8)
            if selected { Text("✓").accessibilityHidden(true) }
        }.padding(14).frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(selected ? ChapterTheme.soft : ChapterTheme.card, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? ChapterTheme.green : .clear))
            .contentShape(Rectangle()).accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct EventCard: View {
    let event: CommunityEvent
    var compact = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(event.date) · \(event.startTime)").font(ChapterTheme.small).foregroundStyle(ChapterTheme.orange)
            Text(event.title).font(ChapterTheme.heading).fixedSize(horizontal: false, vertical: true)
            Text("\(event.venue) · \(event.distance, specifier: "%.1f") miles").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
            if !compact { Text("\(event.languages) · \(event.newcomers) newcomers · Free").font(ChapterTheme.small) }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(ChapterTheme.card, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
            Text(value).font(ChapterTheme.label)
        }
    }
}
