# The Next Chapter

The Next Chapter is an iPhone prototype that helps people settle into new cities and meet others through local events. It helps newcomers decide whether an event feels right for them by showing which languages people speak, who else is new, and what to expect when they arrive. Once they find an event they like, they can put together an outing with a meeting spot, travel plans, and a welcome note.

## Requirements

- **Simulator:** A Mac with full Xcode and an installed iOS Simulator runtime. The latest verified setup was **Xcode 27.2** with an **iPhone 17 simulator running iOS 27.2**.
- **Physical device:** An iPhone running **iOS 17 or later** and an Apple development signing team configured in Xcode. The simulator is the quickest setup and requires no signing account.
- **Credentials and settings:** No test username or password, browser, location permission, or special device settings are required. The repository includes the sample data, fonts, artwork, and app icon. There are no third-party packages or backend services to install. Once Xcode and the simulator runtime are installed, the demo runs offline.

## Run the app

1. Download the repository as a ZIP from GitHub and extract it, or clone the repository if you already use Git.
2. Open `NextChapter.xcodeproj` in Xcode. If this is your first time opening Xcode, complete its setup prompts. If no iPhone simulator is available, install an iOS runtime in **Xcode → Settings → Components**.
3. Select the **NextChapter** scheme and an iPhone simulator in the Xcode toolbar. Use **iPhone 17** if it is available.

## Use the demo

| Tab or screen | What you can do |
| --- | --- |
| **Discover** | Browse listed events. Search by event title, venue, category, or tag. Use **Event Size** to narrow the list, or **Filters & sort** for age range, category, tag, distance, price, date, and start time. Sort by soonest, nearest, or lowest price. **Browse welcoming events** opens preset filters. |
| **Event details** | Tap a card to see the event time, venue, cost, and arrival information. Tap **Save event** to add it to Saved or **Join event** to mark yourself as joined. Tap the same control again to undo the choice. **See people attending** shows the sample attendee list, and **Plan to go together** opens the outing planner. |
| **Saved** | Reopen saved events. Tap **Event reminder** and choose one day before, two hours before, 30 minutes before, or Off. The app stores your choice locally. |
| **Profile** | Set your cultural connection, event language, interests, distance, and budget. Tap **Save Profile**. In the confirmation dialog, choose **See Matches** to open the results or **Back to Profile** to keep editing. |
| **Plans** | Start a new outing with **+ Plan an outing** or open a confirmed outing to review, edit, or cancel it. |

### Plan an outing

1. Choose an event and enter an outing name, or use the suggested name.
2. Select any sample companions you want to include. Choose the meeting point and meet-up time, then select transport and a welcome note.
3. Check the invite-only visibility, choose a group reminder, and tap **Review outing**.
4. Turn on **I have checked the details**, then tap **Confirm outing**. The outing appears in **Plans**.

The top-left **Back** button returns to the previous step. Tap **Change event** below the main button to return to the event picker. The planner keeps your draft and clears the meet-up time if you select a different event. To exit, tap **Cancel** and confirm. From a confirmed plan, **Edit arrangements** updates the existing outing after you review and save your changes.

To start with a clean demo, go to **Profile → Reset demo** and confirm. This clears saved events, joined status, reminders, preferences, and outings for this app on the current device or simulator.

## Prototype limits

- The three event listings, attendees, dates, prices, distances, and travel estimates are fixed sample data. **Free & indoors this weekend** uses the sample weekend of October 24–25, 2026.
- Joining records your choice on the device. The demo does not reserve a spot, send invitations or notifications, or charge for paid sample listings.
- **Add to calendar** shows a preview. Calendar entries, live routes, and live travel updates are outside the demo.
- Saved events, joined status, reminder choices, profile preferences, and confirmed outings persist on the current device. There is no account, backend, or cross-device sync. An outing draft stays in the planner until you confirm it or exit.

[Figma design](https://www.figma.com/design/xV7mUK7j6mZ8BOcHfFqvgR/Untitled?node-id=1-285)
