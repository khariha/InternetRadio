# InternetRadio

InternetRadio is a SwiftUI app that allows users to browse and listen to various radio stations sourced from the Radio Browser API. The app has features for playing/pausing radio streams, browsing by country, and adding favorite stations for easy access.

## Features

- **Browse radio stations**: The app fetches a list of radio stations from the Radio Browser API and presents them in a sorted list. You can scroll through the list to browse available stations.
- **Search**: You can search for stations by name.
- **Play/Pause radio**: You can play or pause the current radio stream by clicking on the play/pause button next to each station.
- **Favorites**: You can add stations to your favorites list for easy access. Just click on the bookmark button next to the station name to add or remove it from your favorites.
- **Navigation**: The app uses SwiftUI's navigation features to allow you to move between the list of all stations and your list of favorite stations.
- **Asynchronous Image Loading**: The app asynchronously loads and caches station favicons for a smooth user experience.

## Code Structure

The project contains several main components:

- `RadioBrowserAPI`: This class handles communication with the Radio Browser API. It fetches the list of stations and handles playing and pausing of radio streams.
- `RadioView`: This SwiftUI view presents the list of all radio stations. It includes a search field for finding stations by name.
- `FavoritesView`: This SwiftUI view shows the user's list of favorite stations.
- `RadioPlayingNowView`: This view shows the currently playing station and provides controls for play/pause.
- `ContentView`: This is the main view of the app, which presents the `RadioView` and `FavoritesView` in a `NavigationView` and includes a toolbar button for navigating to the favorites list.

## Getting Started

To run this app, you need:

- A Mac running macOS Monterey or later.
- Xcode 13 or later.
- An iOS simulator or device running iOS 15 or later.

To run the app:

1. Open the `InternetRadio.xcodeproj` project in Xcode.
2. Choose your target device or simulator.
3. Click the Run button.

## Future Work

In the future, we plan to add more features to InternetRadio, such as:

- Support for additional countries.
- User accounts for syncing favorites across devices.
- More detailed station information.
- Support for more audio formats.
