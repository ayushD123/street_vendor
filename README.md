# Street Vendor Tracking App

A mobile application that helps track and locate street vendors/hawkers in real-time.

## Features

1. Track street vendors/hawkers
2. Display vendor locations on a map
3. GPS navigation to vendor locations
4. User-contributed vendor location updates
5. Real-time location updates for mobile vendors

## Project Structure

```
street-vendor/
├── backend/           # Django backend
│   ├── manage.py
│   └── backend/
├── mobile_app/        # Flutter mobile app
│   ├── lib/
│   └── pubspec.yaml
├── venv/             # Python virtual environment
└── requirements.txt  # Python dependencies
```

## Setup Instructions

### Backend Setup

1. Activate virtual environment:
   ```bash
   # Windows
   .\venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```bash
   cd backend
   python manage.py migrate
   ```

4. Start the development server:
   ```bash
   python manage.py runserver
   ```

### Mobile App Setup

1. Install Flutter dependencies:
   ```bash
   cd mobile_app
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Technology Stack

- Backend: Django + Django REST Framework
- Mobile App: Flutter
- Database: PostgreSQL (to be configured)
- Maps Integration: Google Maps API
- Authentication: JWT

## Development Status

🚧 Project is currently in initial setup phase 🚧 