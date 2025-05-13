# SaveMe – Personal Finance App
SaveMe is a personal finance management app that helps you track your income, expenses, budgets, and billing reminders. Built using SwiftUI and Firebase, it aims to simplify financial planning by providing real-time expense tracking, budgeting tools, and automated billing notifications.

## Features
### 💰 Income and Expense Tracking
* Add, edit, and delete transactions.
* Categorize expenses and incomes.

### 📊 Budget Management
* Set budget limits for various categories.
* Track spending against your budget.
* Visualize your financial health.

### 📅 Billing Reminders
* Set billing reminders with due dates.
* Get push notifications before bills are due.

### 🔔 Notifications
* Receive timely reminders for upcoming bills.
* Notification timing (1 day before due).

### 🔐 Secure Authentication
* User authentication with Firebase.
* Secure user data storage in Firestore.

---

# Getting Started
## Prerequisites
* Xcode 14+
* Firebase Account

## Firebase Setup
### 1. Create a Firebase Project
* Go to the Firebase Console.
* Create a new project.

### 2. Add iOS App to Firebase
* Register your app with the iOS bundle ID.
* Download the GoogleService-Info.plist file.

### 3. Add the GoogleService-Info.plist File
* Copy the downloaded GoogleService-Info.plist to the root directory of your Xcode project.
* Enable Firestore and Authentication

### 4. Enable Firestore Database.
* Enable Email/Password authentication in Firebase Auth.

## Plist Setup
The project contains a file named `Info.plist` which is required for the app to work.
* Rename the `Info.plist.sample.plist` to `Info.plist`
* Fill the item0 in URL Schemes with `YOUR_REVERSED_CLIENT_ID` from firebase.

## Build the app
Run the app on the simulator or a physical device.
