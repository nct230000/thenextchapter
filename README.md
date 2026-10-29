<<<<<<< HEAD
NEEDS TO BE EDITED!!

Explains how your UI functions. 

Include specific requirements for running your UI (e.g., test user ID/password, browser or device settings). 
Instructions should be clear enough for anyone to set up and run your UI. 

It’s your responsibility to include any installation requirements,operating instructions, and any limitations in the implementation. 
Ideally, the prototype should be executable without needing to install additional software.
=======
# The Next Chapter

A native SwiftUI iOS demo of the supplied Figma prototype. Includes the original Inter and DM Serif Display fonts, cream/green design tokens, and exported event artwork. No third-party runtime dependencies or account setup.

## Run

1. Open `NextChapter.xcodeproj` in Xcode.
2. Select the **NextChapter** scheme and an iPhone simulator.
3. Press **⌘R**. Deployment target: iOS 17 or later.

For a physical iPhone, choose your signing team in **Signing & Capabilities** first.

The project was built and tested with Xcode 26.3 on the iPhone 16e simulator running iOS 26.3.

## Demo walkthrough

- **Discover:** browse the two sample events, filter by food/culture or free indoor events, and open event details.
- **Event details:** save/unsave, join/leave, inspect attendees, and start an outing.
- **Saved:** revisit saved events and change the local reminder preference.
- **Profile:** choose culture, language, interests, and distance/budget; view matching sample events.
- **Plans:** choose an event, name the outing, select company, pick meeting arrangements and transport, choose a welcome note, and review visibility/reminder settings. Confirm the review to save the plan. Reopen a plan to edit or cancel it.
- **Reset:** Profile → Reset demo clears this app’s local progress.

Saved events, joined state, reminder choices, preferences, and confirmed outings survive app relaunches. Unsaved planner changes are discarded only after confirmation. Changing an existing plan updates it without creating a duplicate.

## Demo boundaries

Events, attendees, travel estimates, and October 24–25 dates are sample content preserved from the prototype, not live listings. Joining does not reserve a place; invitations and notifications are not sent. Calendar is a preview and does not write to the device calendar. All app data stays in local UserDefaults. Visibility is invite-only; no backend or authentication is included.

The Figma file contains 51 frames, many representing selection states. The app implements these as stateful screens rather than 51 separate pages. Native navigation stacks, a system tab bar, sheets, and a review toggle provide iOS behavior. The user approved prototype/layer-text references for secondary screens after Figma reached its tool-call limit. Some single-option prototype pickers are consolidated into working choice cards; the outing name additionally supports free text. The app retains the non-glass appearance on iOS 26 to match the supplied design.

## Source map

- `NextChapter/Models.swift`: sample data, local persistence, preferences, and outing validation.
- `NextChapter/DesignSystem.swift`: reusable typography, colors, buttons, cards, and page layouts.
- `NextChapter/EventViews.swift`: discovery, filtering, event details, saved events, reminders, and attendees.
- `NextChapter/ProfileViews.swift`: preferences, matching, about, and reset.
- `NextChapter/PlanViews.swift`: planner, review, confirmation, plan management, and calendar preview.
- `NextChapter/Resources`: bundled fonts and their SIL Open Font License notices.
- `NextChapter/Assets.xcassets`: named design colors and the original SVG artwork.

## Verification

Use **⌘U** to run the unit tests. They cover persistence after relaunch, save/unsave, joined state, reminder/preferences storage, incomplete-plan rejection, create/edit/cancel behavior, and reset isolation.

Command-line build and test (choose an installed simulator name):

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project NextChapter.xcodeproj -scheme NextChapter \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO test
```

Manual simulator checks performed during implementation: home layout and tab labels, original event artwork, save/join state changes, the complete seven-step outing flow, required-field validation, review-gated confirmation, preference selection and matching, and saved events/outings after relaunch.

Design source: https://www.figma.com/design/xV7mUK7j6mZ8BOcHfFqvgR/Untitled?node-id=1-346
>>>>>>> a8bb9ff (Build SwiftUI demo)
