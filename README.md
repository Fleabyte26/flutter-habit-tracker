# Flutter Habit Tracker App

A mobile application built with Flutter that helps users build and maintain daily habits through tracking, reminders, and progress visualization.

---

## User Stories

### 1. User Registration
**As a** new user,
**I want to** create an account with my name, email, and password,
**So that** I can access my personal habit data securely across sessions.

**Acceptance Criteria:**
- User can enter name, email, and password
- Validation is shown for empty or invalid fields
- A success message is shown upon registration

---

### 2. User Login
**As a** registered user,
**I want to** log in with my email and password,
**So that** I can access my habits and progress from any session.

**Acceptance Criteria:**
- User can log in with valid credentials
- An error message is shown for incorrect credentials
- User is redirected to the Home screen upon successful login

---

### 3. Home Screen
**As a** logged-in user,
**I want to** see all my habits listed on the home screen,
**So that** I can quickly view and manage my daily habits.

**Acceptance Criteria:**
- All habits are displayed in a scrollable list
- Each habit shows its name, category, and completion status for today
- A button is available to add a new habit

---

### 4. Add a New Habit
**As a** user,
**I want to** create a new habit by entering a name, category, and frequency,
**So that** I can start tracking a new goal.

**Acceptance Criteria:**
- User can enter a habit name, select a category, and set a frequency (daily/weekly)
- The new habit appears on the home screen after saving
- Validation prevents empty habit names from being saved

---

### 5. Habit Detail Screen
**As a** user,
**I want to** tap on a habit to view its details and history,
**So that** I can monitor my progress over time.

**Acceptance Criteria:**
- The detail screen shows the habit name, category, frequency, and streak count
- A calendar or list view shows past completion dates
- User can mark the habit as complete for today from this screen

---

### 6. Edit and Delete a Habit
**As a** user,
**I want to** edit or delete an existing habit,
**So that** I can keep my habit list up to date.

**Acceptance Criteria:**
- User can edit the habit name, category, and frequency
- User can delete a habit with a confirmation prompt
- Changes are reflected immediately on the home screen

---

### 7. Local Data Persistence
**As a** user,
**I want to** have my habits and progress saved locally on my device,
**So that** my data is available even when I am offline.

**Acceptance Criteria:**
- Habit data is stored using local storage (e.g., SQLite or SharedPreferences)
- Data persists after the app is closed and reopened
- No data is lost when the device loses internet connection

---

### 8. Settings Screen
**As a** user,
**I want to** access a settings screen where I can update my profile and app preferences,
**So that** I can personalize my experience.

**Acceptance Criteria:**
- User can update their name and email
- User can toggle dark/light mode
- User can enable or disable notifications

---

### 9. Notifications and Reminders
**As a** user,
**I want to** receive daily reminders for my habits,
**So that** I don't forget to complete them.

**Acceptance Criteria:**
- User can set a reminder time for each habit
- A push notification is sent at the specified time
- User can turn off notifications for specific habits from the settings screen

---

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Local Storage:** SQLite / SharedPreferences
- **Notifications:** Flutter Local Notifications
- **Version Control:** GitHub
