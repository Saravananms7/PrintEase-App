# PrintEase - Simplify Your Printing

**PrintEase** is a smart print management application designed for college campuses and print shops. Students can upload documents, choose printing preferences, make payments, and track their requests. Shopkeepers manage print jobs easily through a dedicated Windows app.

---

## About the Project
PrintEase was created to solve the inefficiencies faced by students and shopkeepers in traditional printing workflows. It offers a seamless, modern experience tailored for college campuses, combining document management, payments, and real-time updates — all powered by Flutter and Supabase.

---

## Features

### Student Side
- 📄 Upload documents (max 1MB file size)
- 🌟 Select printing preferences (single/double side, color/B&W)
- 📜 View print history
- 🛠️ Cancel unprinted requests
- 🔔 Notifications when print is ready or canceled
- 💳 Secure pre-payment system (non-refundable)

### Shopkeeper Side
- 🖥️ View pending print requests
- ✏️ Manually update print status
- 🧹 Auto-deletion of old documents to save storage
- 🛡️ Secure access via Supabase

---

## Tech Stack
- **Frontend (Students):** Flutter (Mobile App)
- **Frontend (Shopkeepers):** Flutter (Windows App)
- **Backend:** Supabase (Auth, Database, Storage)
- **Payments:** Integrated (users pay processing fees)

---

## Setup Instructions

### Prerequisites
- Flutter SDK
- Supabase Project
- Payment Gateway Account (e.g., Stripe, Razorpay)

### Running the Student App
```bash
git clone https://github.com/yourusername/printease.git
cd printease
flutter pub get
flutter run
```

### Running the Shopkeeper Windows App
```bash
cd printease
flutter run -d windows
```

> ⚡ Remember to configure your Supabase credentials in the project before running.

---

## Folder Structure
```
/printease
 |-- /lib (core Flutter app files)
 |    |-- /screens (UI Screens)
 |    |-- /services (Supabase and payment integrations)
 |    |-- /models (Data models)
 |    |-- /widgets (Reusable widgets)
 |-- /assets (App assets like images, logos)
 |-- /windows_shopkeeper (Windows-specific code for shopkeeper app)
 |-- README.md
```

---


## Current Highlights
- 🔄 Real-time order status updates
- 🖨️ Automatic printer integration with store software
- 📊 Admin dashboard with analytics and reports
- 📬 Email notifications for print status updates

---

## Future Enhancements
- 🌐 Online tracking dashboard for students
- 🔹 QR Code-based document pickup
- 🎁 Loyalty rewards system for frequent users

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Credits

- Flutter Developers Community
- Supabase Team
- Payment Gateway Providers

---

## Connect with Me

If you liked this project, feel free to check out more of my work on [GitHub](https://github.com/yourusername)!  
⭐ Star this repo to support future updates!

---

Made with ❤️ by Saravanan

