# Chess Trainer App - UI Screens Documentation

This document describes the visual appearance and layout of each screen in the Chess Trainer app.

## Screen Flow
```
Search Screen → Games List Screen → Analysis Detail Screen
     ↓                ↓                      ↓
  [Analyze]      [Tap Game]            [Back Button]
```

---

## 1. Search Screen (Entry Point)

### Layout
```
┌─────────────────────────────────────┐
│ ← Chess Trainer              [Menu] │  <- AppBar (deep purple)
├─────────────────────────────────────┤
│                                     │
│           [🧠 Brain Icon]           │  <- Large icon (80px)
│                                     │
│     Analyze Your Chess Games        │  <- Title (24px, bold)
│                                     │
│  Enter your Chess.com username      │  <- Subtitle (16px, grey)
│      to get started                 │
│                                     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 Chess.com Username       │   │  <- Text input field
│  │ [Enter username]            │   │     with person icon
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │        Analyze              │   │  <- Elevated button
│  └─────────────────────────────┘   │     (or spinner when loading)
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### States
1. **Initial State**: Empty text field, enabled button
2. **Loading State**: Button shows circular progress indicator, input disabled
3. **Error State**: Error message shown below text field in red
4. **Success**: Navigation to Games List Screen

### Visual Elements
- **Background**: White
- **AppBar**: Deep purple with white text
- **Brain Icon**: Deep purple, 80px
- **Title**: Black, 24px, bold, centered
- **Subtitle**: Grey, 16px, centered
- **Input Field**: White with border, person icon prefix
- **Button**: Deep purple background, white text, 16px padding

---

## 2. Games List Screen

### Layout
```
┌─────────────────────────────────────┐
│ ← {username}'s Games         [Menu] │  <- AppBar (deep purple)
├─────────────────────────────────────┤
│ ╔═══════════════════════════════╗   │
│ ║ WhitePlayer vs BlackPlayer    ║   │  <- Game Card
│ ║                               ║   │
│ ║ [🏆 White wins] [⏱ 10+0]     ║   │  <- Result & time chips
│ ║ 2024-01-15                    ║   │  <- Date
│ ║                            → ║   │  <- Chevron
│ ╚═══════════════════════════════╝   │
│                                     │
│ ╔═══════════════════════════════╗   │
│ ║ Player1 vs Player2            ║   │  <- Another game card
│ ║                               ║   │
│ ║ [🏆 Draw] [⏱ 5+3]            ║   │
│ ║ 2024-01-14                    ║   │
│ ║                            → ║   │
│ ╚═══════════════════════════════╝   │
│                                     │
│ [Pull down to refresh]              │
│                                     │
└─────────────────────────────────────┘
```

### States
1. **Loading State**: Centered circular progress indicator
2. **Empty State**: 
   - Inbox icon (60px, grey)
   - "No games found" message
   - "Try analyzing games first" subtitle
3. **Error State**:
   - Error icon (60px, red)
   - Error message
   - Retry button
4. **Data State**: Scrollable list of game cards

### Game Card Visual Elements
- **Card**: White background, subtle shadow, rounded corners
- **Players**: Bold text, truncated if too long
- **"vs"**: Regular text between players
- **Result Chip**: Grey background, rounded, icon + text
- **Time Chip**: Grey background, rounded, timer icon + time
- **Date**: Small grey text (12px)
- **Chevron**: Grey arrow on right side
- **Tap Area**: Entire card is tappable

### Pull-to-Refresh
- Standard Material Design refresh indicator at top
- Shows during refresh operation

---

## 3. Analysis Detail Screen

### Layout
```
┌─────────────────────────────────────┐
│ ← Game Analysis              [Menu] │  <- AppBar (deep purple)
├─────────────────────────────────────┤
│ ╔═════════════════════════════════╗ │
│ ║ Game Information                ║ │  <- Metadata card
│ ║                                 ║ │
│ ║ 👤 White:    Player1            ║ │
│ ║ 👤 Black:    Player2            ║ │
│ ║ 🏆 Result:   White wins         ║ │
│ ║ ⏱ Time:      10+0              ║ │
│ ║ 📅 Date:      2024-01-15        ║ │
│ ║ ⚠️  Mistakes:  3                ║ │
│ ╚═════════════════════════════════╝ │
│                                     │
│ ╔═════════════════════════════════╗ │
│ ║     [📋 Chess Board Grid]       ║ │  <- Board placeholder
│ ║                                 ║ │     (300px height)
│ ║   Interactive board coming      ║ │
│ ║         soon                    ║ │
│ ╚═════════════════════════════════╝ │
│                                     │
│ ╔═════════════════════════════════╗ │
│ ║ Mistakes                        ║ │  <- Mistakes section
│ ║                                 ║ │
│ ║ [Move 12]           Loss: 2.5   ║ │
│ ║                                 ║ │
│ ║ ┌─────────────────────────────┐ ║ │
│ ║ │ Your Move │ Nf3    │ [-0.8] │ ║ │  <- Red border
│ ║ └─────────────────────────────┘ ║ │
│ ║ ┌─────────────────────────────┐ ║ │
│ ║ │ Best Move │ Nd4    │ [+1.7] │ ║ │  <- Green border
│ ║ └─────────────────────────────┘ ║ │
│ ║ ─────────────────────────────── ║ │
│ ║                                 ║ │
│ ║ [Move 18]           Loss: 1.8   ║ │
│ ║ ...                             ║ │
│ ╚═════════════════════════════════╝ │
└─────────────────────────────────────┘
```

### States
1. **Loading State**: Centered circular progress indicator
2. **Error State**: Error icon, message, and retry button
3. **No Mistakes**: 
   - Green check icon (60px)
   - "No Mistakes Found!" message
   - "This was a perfectly played game" subtitle
4. **Data State**: Scrollable content with all sections

### Visual Elements

#### Game Information Card
- **White background** with shadow
- **Icons**: 20px, grey color
- **Labels**: Grey text, 110px width
- **Values**: Bold black text

#### Chess Board Placeholder
- **Height**: 300px
- **Background**: Light grey (Colors.grey[200])
- **Border**: Rounded corners
- **Content**: Centered grid icon, title, and subtitle in grey

#### Mistakes Section Card
- **Card header**: "Mistakes" in 20px bold text
- **Dividers**: Between each mistake

#### Mistake Display
1. **Header Row**:
   - Move badge: Red background, white text, rounded
   - Loss indicator: Red bold text on right

2. **Player Move Container**:
   - **Border**: Red with transparency
   - **Background**: Light red with transparency
   - **Layout**: Label (80px) | Move (expanded) | Eval badge
   - **Eval Badge**: Red background, white text

3. **Best Move Container**:
   - **Border**: Green with transparency
   - **Background**: Light green with transparency
   - **Layout**: Same as player move
   - **Eval Badge**: Green background, white text

### Evaluation Formatting
- Positive: "+2.5" (advantage for white)
- Negative: "-1.3" (advantage for black)
- Large positive: "+M" (mate for white)
- Large negative: "-M" (mate for black)

---

## Color Scheme

### Primary Colors
- **Primary**: Deep Purple (`Colors.deepPurple`)
- **Background**: White
- **Surface**: White

### Semantic Colors
- **Success/Best Move**: Green
- **Error/Mistake**: Red
- **Info**: Deep Purple
- **Warning**: Orange/Yellow

### Text Colors
- **Primary Text**: Black
- **Secondary Text**: Grey (Colors.grey[700])
- **Hint Text**: Light Grey (Colors.grey)
- **On Primary**: White

### UI Element Colors
- **App Bar**: Deep Purple with inverse primary color
- **Cards**: White with shadow
- **Chips**: Grey[200] background, Grey[700] text
- **Icons**: Grey[600]

---

## Typography

### Font Sizes
- **Large Title**: 24px
- **Title**: 20px
- **Body**: 16px
- **Button**: 18px
- **Caption**: 14px
- **Small Caption**: 12px

### Font Weights
- **Bold**: Headings, player names, values
- **Medium**: Labels, secondary information
- **Regular**: Body text, descriptions

---

## Spacing

### Padding
- **Screen edges**: 24px
- **Card padding**: 16px
- **Card content**: 12px
- **Between elements**: 8px, 12px, 16px, 24px, 48px (multiples of 4dp)

### Margins
- **Card margins**: Horizontal 12px, Vertical 6px
- **Section spacing**: 16-24px

---

## Interactions

### Tap Targets
- **Minimum size**: 48x48 dp (Material Design standard)
- **Cards**: Entire card is tappable
- **Buttons**: Full button area
- **Text fields**: Full field area

### Feedback
- **Buttons**: Ripple effect on tap
- **Cards**: Elevation change on tap
- **Text fields**: Focus highlight
- **Loading**: Circular progress indicator
- **Pull-to-refresh**: Standard Material indicator

### Animations
- **Navigation**: Standard slide transition
- **Loading**: Rotating circular progress
- **Refresh**: Pull-down indicator
- **State changes**: Smooth transitions

---

## Accessibility

### Screen Reader Support
- All interactive elements have semantic labels
- Proper heading hierarchy
- Meaningful button labels

### Contrast
- Text meets WCAG AA standards
- Sufficient contrast between text and background
- Color not used as sole indicator

### Touch Targets
- All tap targets are at least 48x48 dp
- Sufficient spacing between elements
- Clear visual feedback on interaction

---

## Responsive Design

### Layout Behavior
- **Portrait**: Standard vertical layout
- **Landscape**: Same layout with scrolling
- **Small screens**: Content adapts with scrolling
- **Large screens**: Content centered, max width applied

### Text Wrapping
- Player names: Ellipsis if too long
- Error messages: Wrap to multiple lines
- Move notation: Single line
- Dates: Fixed format

---

## Material Design 3

This app uses Material Design 3 (Material You) components:
- ✅ `useMaterial3: true` in theme
- ✅ Color scheme from seed color
- ✅ Elevated buttons with proper styling
- ✅ Cards with proper elevation
- ✅ Text fields with Material 3 styling
- ✅ App bar with Material 3 styling
- ✅ Icons from Material Icons library

---

## Notes for Future UI Development

1. **Chess Board**: Will need chess board widget (chess_board package or custom)
2. **Move Replay**: Will need animation for move progression
3. **Dark Mode**: Theme data needs dark variant
4. **Tablets**: May benefit from two-pane layout
5. **Landscape**: Could optimize layout for landscape mode
6. **Accessibility**: Add more screen reader support
7. **Localization**: Prepare for i18n support