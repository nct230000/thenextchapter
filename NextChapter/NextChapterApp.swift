import SwiftUI

@main struct NextChapterApp: App {
    @State private var store = AppStore(reset: ProcessInfo.processInfo.arguments.contains("--reset-demo"))
    var body: some Scene {
        WindowGroup { RootView().environment(store).preferredColorScheme(.light) }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                NavigationStack {
                    Group {
                        switch tab {
                        case .discover: DiscoverView(selectedTab: $store.selectedTab)
                        case .saved: SavedView(selectedTab: $store.selectedTab)
                        case .plans: PlansView()
                        case .profile: ProfileView(selectedTab: $store.selectedTab)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("the next chapter.").font(ChapterTheme.label).foregroundStyle(ChapterTheme.ink)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink { FilterView() } label: {
                                Text("⌖ Richardson").font(ChapterTheme.small).foregroundStyle(ChapterTheme.muted)
                            }.accessibilityLabel("Browse events near Richardson")
                        }
                    }
                    .toolbarBackground(ChapterTheme.cream, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label { Text(tab.rawValue) } icon: { Image(uiImage: tabIcon(tab.glyph)) }
                }.tag(tab)
            }
        }.tint(ChapterTheme.green).font(ChapterTheme.body)
            .toolbarBackground(ChapterTheme.card, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }
    private func tabIcon(_ glyph: String) -> UIImage {
        // The Figma navigation icons are monochrome text glyphs, not SF Symbols.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
        return renderer.image { _ in
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: UIColor.black]
            let size = glyph.size(withAttributes: attributes)
            glyph.draw(at: CGPoint(x: (24 - size.width) / 2, y: (24 - size.height) / 2), withAttributes: attributes)
        }.withRenderingMode(.alwaysTemplate)
    }
}
