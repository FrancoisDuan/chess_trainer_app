# Chess Trainer App

A Flutter mobile application for analyzing Chess.com games and identifying mistakes to improve your chess skills.

## Features

### Current Implementation

1. **Search Screen**
   - Enter Chess.com username
   - Analyze games with loading indicator
   - Error handling and validation
   - Navigate to Games List on success

2. **Games List Screen**
   - Display all analyzed games for a user
   - Show game metadata (players, result, time control, date)
   - Pull-to-refresh functionality
   - Tap to view detailed analysis

3. **Analysis Detail Screen**
   - Full game metadata display
   - List of all mistakes found
   - Move comparison (player move vs best move)
   - Evaluation before/after each mistake
   - Chess board placeholder (interactive board coming soon)

4. **Backend Integration**
   - HTTP client for backend API communication
   - Endpoints implemented:
     - `POST /analyze` - Analyze games for username
     - `GET /api/user/{username}/games` - List analyzed games
     - `GET /api/analysis/{game_id}` - Get detailed analysis
   - Graceful error handling

5. **Data Models**
   - User, Game, Analysis, and Mistake models
   - JSON serialization/deserialization
   - Type-safe data handling

## Technical Stack

- **Framework**: Flutter 3.10.8+
- **Language**: Dart
- **HTTP Client**: http package (v1.1.0)
- **Design**: Material Design 3
- **Backend**: Connects to http://localhost:8000

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user.dart
│   ├── game.dart
│   ├── analysis.dart
│   └── mistake.dart
├── services/                          # API service layer
│   └── chess_trainer_api_service.dart
└── screens/                           # UI screens
    ├── search_screen.dart
    ├── games_list_screen.dart
    └── analysis_detail_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10.8 or higher
- Backend API running at http://localhost:8000
- iOS Simulator, Android Emulator, or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/FrancoisDuan/chess_trainer_app.git
   cd chess_trainer_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
```

### Backend Setup

Ensure the backend API is running at `http://localhost:8000`. The app expects the following endpoints:

- `POST /analyze` - Accepts JSON with `username` field
- `GET /api/user/{username}/games` - Returns array of game objects
- `GET /api/analysis/{game_id}` - Returns analysis object with mistakes

## Future Enhancements

- Interactive chess board widget
- Move replay functionality
- Game filtering and sorting
- Dark mode support
- Offline data caching
- Performance statistics dashboard

## Development Notes

- Uses Material Design 3 components
- Implements proper state management
- Follows Flutter best practices
- Includes error handling for all API calls
- Proper resource disposal (controllers, HTTP client)

## License

This project is a private Flutter application.
