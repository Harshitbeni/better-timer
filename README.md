# BetterTimer setup guide

This project explains how to create the **BetterTimer** multi-platform app in Xcode. Follow these steps on a Mac with Xcode installed.

## 1) Create the initial project
1. Open **Xcode**.
2. Choose **File → New → Project…**.
3. In the template chooser, select **App** under the **iOS** tab and click **Next**.
4. In the **Choose options for your new project** window, fill in each field exactly like this (use the screenshot as a reference):
   - **Product Name:** `BetterTimer` (this is the app’s display name)
   - **Team:** pick your Apple ID/Personal Team. If it shows “None,” click **Add Account…** and sign in with your Apple ID, then return and select it.
   - **Organization Identifier:** `com.yourname` (replace `yourname` with something unique, like your last name)
   - **Bundle Identifier:** auto-fills to `com.yourname.BetterTimer` based on the Organization Identifier and Product Name—leave it as-is.
   - **Interface:** choose **SwiftUI**
   - **Language:** choose **Swift**
   - **Testing System:** leave as **None** (you can add tests later)
   - **Storage:** leave as **None**
   - **Include Tests:** **check** this box (even though Testing System is “None,” Xcode still adds basic test targets)
5. Click **Next**, choose where to save the project, and click **Create**.

## 2) Add additional platform targets
Add macOS, iOS, and watchOS SwiftUI lifecycle targets so the app can run on each platform.

### Add a macOS App target
1. In Xcode’s menu, pick **File → New → Target…**.
2. Select **macOS > App** (SwiftUI lifecycle) and click **Next**.
3. Set the **Product Name** (e.g., `BetterTimer-macOS`), ensure **Interface** is **SwiftUI**, **Language** is **Swift**, then click **Finish**.
4. When prompted, choose **Activate** to make the new scheme active.

### Add an additional iOS App target (if you want a separate build)
1. Choose **File → New → Target…**.
2. Select **iOS > App** (SwiftUI lifecycle) and click **Next**.
3. Name it (e.g., `BetterTimer-iOS`), confirm **SwiftUI** and **Swift**, and click **Finish**.
4. Click **Activate** when asked.

### Add a watchOS App target
1. Choose **File → New → Target…**.
2. Select **watchOS > App** (SwiftUI) and click **Next**.
3. Name it (e.g., `BetterTimer-watchOS`), make sure **SwiftUI** and **Swift** are selected, and click **Finish**.
4. Click **Activate** if prompted.

> Tip: Each target gets its own folder group in the Xcode navigator. You can share Swift files between targets by checking the boxes for the platforms that should include each file in the File Inspector.

## 3) Configure Signing & Capabilities with an App Group
You want all targets to share data using the same App Group.

1. In the project navigator, click the **project** (top-level blue icon).
2. Under **Targets**, select each target (iOS, macOS, watchOS) one at a time.
3. Go to the **Signing & Capabilities** tab.
4. Click the **+ Capability** button and choose **App Groups**.
5. Add a new App Group identifier, for example: `group.com.yourname.bettertimer`.
6. Repeat for **every** target so they all use the identical App Group ID.

## 4) Verify shared group in code (optional)
After capabilities are set, you can access the App Group container with:
```swift
let sharedURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourname.bettertimer")
```
Use this URL to store shared files or a Core Data store that all platform targets can read.

## 5) Run and test
- Pick a scheme (iOS, macOS, or watchOS) from the scheme selector near the Xcode run button.
- Choose an appropriate simulator/device.
- Press **⌘R** to run. Use **⌘U** to run the test suite created by Xcode.

You now have a multi-platform SwiftUI project with a shared App Group configured across all targets.
