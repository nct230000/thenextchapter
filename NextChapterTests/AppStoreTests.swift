import XCTest
@testable import NextChapter

final class AppStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!
    override func setUp() {
        suite = "NextChapterTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }
    override func tearDown() { defaults.removePersistentDomain(forName: suite) }

    func testSavedJoinedAndPreferencesSurviveRelaunch() {
        let store = AppStore(defaults: defaults)
        store.toggleSaved("potluck")
        store.toggleJoined("coffee")
        store.setReminder("2 hours before", for: "potluck")
        var preferences = Preferences()
        preferences.culture = "Turkish"
        store.setPreferences(preferences)
        let relaunched = AppStore(defaults: defaults)
        XCTAssertEqual(relaunched.state.saved, ["potluck"])
        XCTAssertEqual(relaunched.state.joined, ["coffee"])
        XCTAssertEqual(relaunched.state.reminders["potluck"], "2 hours before")
        XCTAssertEqual(relaunched.state.preferences.culture, "Turkish")
        relaunched.toggleSaved("potluck")
        XCTAssertTrue(AppStore(defaults: defaults).state.saved.isEmpty)
    }

    func testInvalidOutingCannotBeSaved() {
        let store = AppStore(defaults: defaults)
        XCTAssertFalse(store.saveOuting(Outing()))
        var outing = validOuting()
        outing.name = "  \n "
        XCTAssertFalse(store.saveOuting(outing))
        XCTAssertTrue(store.state.outings.isEmpty)
    }

    func testCreateEditCancelOutingAndPersistence() {
        let store = AppStore(defaults: defaults)
        var outing = validOuting()
        XCTAssertTrue(store.saveOuting(outing))
        outing.transport = "Car"
        XCTAssertTrue(store.saveOuting(outing))
        let relaunched = AppStore(defaults: defaults)
        XCTAssertEqual(relaunched.state.outings.count, 1)
        XCTAssertEqual(relaunched.state.outings.first?.transport, "Car")
        XCTAssertEqual(relaunched.state.outings.first?.people, ["Maya R."])
        relaunched.cancelOuting(outing.id)
        XCTAssertTrue(AppStore(defaults: defaults).state.outings.isEmpty)
    }

    func testResetClearsOnlyDemoState() {
        defaults.set("keep", forKey: "unrelated")
        let store = AppStore(defaults: defaults)
        store.toggleSaved("potluck")
        store.toggleJoined("potluck")
        store.saveOuting(validOuting())
        store.reset()
        let relaunched = AppStore(defaults: defaults)
        XCTAssertTrue(relaunched.state.saved.isEmpty)
        XCTAssertTrue(relaunched.state.joined.isEmpty)
        XCTAssertTrue(relaunched.state.outings.isEmpty)
        XCTAssertEqual(defaults.string(forKey: "unrelated"), "keep")
    }
    private func validOuting() -> Outing {
        Outing(name: "Our first Dallas potluck", people: ["Maya R."], meetingPoint: "At the venue entrance", meetingTime: "4:45 PM", transport: "Public transit", note: "Looking forward to meeting everyone!")
    }
}
