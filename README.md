# Medication Reminder App 💊⏰

A mobile application built with **Flutter** to help users manage their medications, doses, and schedules. The app focuses on simplicity, offline-first storage, and clean architecture using MVVM with GetX.

## 📌 Overview

The app allows users to:
- Add medications with name, dosage, frequency, duration, notes, and an optional photo.
- Define custom dose times for each medication and store them in a `medication_schedule` table.
- View all active medications in a clean card-based UI.
- Edit or delete medications with confirmation dialogs.
- Keep medication data stored locally with optional sync support.

## ✨ Features

- User authentication (login / registration).
- Add / edit / delete medications.
- Custom dose time selection using a compact time picker.
- Active Medications screen with:
  - Name, dosage, frequency.
  - Next dose and duration info.
  - Optional note.
  - Edit / Delete actions with dialogs.
- Local database using Floor (SQLite) with `sync_status` flags.
- MVVM architecture + GetX for controllers, navigation, and reactivity.
- Image support for medications (camera / gallery).

## 🧱 Tech Stack

- **Framework:** Flutter  
- **Language:** Dart  
- **Architecture:** MVVM + GetX  
- **Local Storage:** Floor (SQLite)  
- **Backend / Auth:** Supabase (or similar)  
- **Other:** Path Provider, Image Picker, Connectivity, etc.
