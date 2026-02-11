# LoyaltyLite

**Sprint #2 – Project Plan Document**  
Team 03  
Team Lead: Rohith  

---

## 📌 Problem Theme  
Loyalty Platform for Small Businesses

---

## 1. Problem Statement & Solution Overview

Small businesses in Tier-2 and Tier-3 towns face difficulty in building customer loyalty because they do not have access to simple and affordable digital tools to track repeat customers or manage reward programs. Most existing loyalty solutions are complex, costly, or built for large enterprises, making them unsuitable for small shop owners.

Our solution is a mobile-first loyalty management application built using **Flutter and Firebase**. The app enables small business owners to register customers, track visits or purchases, and reward loyal customers digitally in a simple and efficient way.

A mobile application is ideal because shop owners primarily use smartphones, require real-time updates, and need an easy-to-use system without additional hardware or training.

The primary users are small shop owners such as grocery stores, salons, cafés, and local service providers. This problem is especially relevant now due to increased smartphone usage and the growing need for digital transformation among small businesses.

---

## 2. Scope & Boundaries

### ✅ In Scope for Sprint #2

The sprint focuses on building a functional **Minimum Viable Product (MVP)** with core features, including:

- Firebase Authentication for shop owners  
- Firestore database integration  
- Essential Flutter screens:
  - Login  
  - Register  
  - Dashboard  
  - Add Customer  
  - Reward Tracking  
- Basic state management  
- Generating a working Android APK  

### ❌ Out of Scope

The following features are excluded from this sprint:

- Payment integration  
- Push notifications  
- Analytics dashboards  
- Multi-language support  
- Customer-facing mobile application  

---

## 3. Roles & Responsibilities

### 👨‍💼 Rohith – Team Lead
- Project coordination  
- Sprint planning  
- Feature prioritization  
- Supporting Firebase integration  

### 🎨 Amarnath T – Frontend (Flutter) Lead
- Building Flutter UI screens  
- Managing navigation  
- Handling UI state  
- Integrating frontend with Firebase  

### ☁️ Sam Babu P – Firebase Lead
- Firebase Authentication setup  
- Firestore database structure  
- CRUD operations  
- Security rules configuration  

### 🧪 K V Pavan Rohith Ratna – Testing & Deployment Lead
- Manual testing  
- Validating authentication and database flows  
- Generating APK build  
- Maintaining documentation  

---

## 4. Sprint Timeline (4 Weeks)

### 📅 Week 1 – Setup and Design
- Finalize app concept and MVP features  
- Design basic UI wireframes  
- Set up Flutter project structure  
- Create Firebase project  
- Connect Firebase with Flutter app  

### 📅 Week 2 – Core Development
- Implement login and registration flows  
- Configure Firestore collections  
- Build dashboard screen  
- Develop customer registration and data storage  

### 📅 Week 3 – Integration and Testing
- Connect frontend screens with Firebase backend  
- Test CRUD operations  
- Implement form validation and error handling  
- Conduct manual testing on Android devices  

### 📅 Week 4 – MVP Completion and Deployment
- Freeze features  
- Polish UI  
- Fix bugs  
- Perform final testing  
- Generate APK build  
- Prepare for demo and submission  

---

## 5. Deployment and Testing Plan

Testing will include:

- Manual testing of login and registration flows  
- Firestore read/write operations  
- Navigation between screens  
- Data consistency validation  
- Basic Flutter widget testing (where applicable)  

Deployment Plan:

- Generate APK using Flutter build tools  
- Share APK via Google Drive  
- (Optional) Host web version using Firebase Hosting  

---

## 6. Minimum Viable Product (MVP)

The MVP will include:

- Shop owner authentication using Firebase  
- Customer registration  
- Reward / visit tracking  
- Real-time Firestore data synchronization  
- Responsive Flutter UI  
- Demo-ready APK build  

---

## 7. Functional Requirements

The application must:

- Allow users to register, log in, and log out securely  
- Enable shop owners to add and view customer data  
- Store and retrieve customer and reward data from Firestore  
- Update dashboard in real time based on database changes  

---

## 8. Non-Functional Requirements

The application should:

- Provide smooth UI transitions  
- Be responsive across different screen sizes  
- Support at least 100 concurrent users  
- Enforce security using Firebase Authentication and Firestore rules  
- Ensure reliable real-time data synchronization  

---

## 9. Success Metrics

The sprint will be considered successful if:

- All MVP features are implemented and functional  
- Firebase Authentication and Firestore are correctly integrated  
- APK builds without errors  
- The project receives positive feedback during the mentor demo  

---

## 10. Risks and Mitigation

### ⚠️ Risk: Firebase configuration errors  
Mitigation: Use predefined Firestore schema and sample data.

### ⚠️ Risk: UI and integration issues  
Mitigation: Early integration and testing during Week 3.

### ⚠️ Risk: Time constraints  
Mitigation: Strict focus on MVP features and avoidance of scope creep.

---

## 🚀 Tech Stack

- Flutter  
- Dart  
- Firebase Authentication  
- Cloud Firestore  
- Android APK Deployment  

---

## 📱 Project Status

Currently in Sprint #2 – MVP Development Phase.
