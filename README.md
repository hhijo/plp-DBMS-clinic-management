# Clinic Booking & Management System

## 📌 Overview
This project is a **relational database management system (RDBMS)** built in **MySQL** for managing a clinic’s operations.  
It covers core functionalities such as patient registration, staff/doctor management, appointments, diagnoses, prescriptions, billing, and insurance.  

The system is designed to demonstrate:
- Proper relational schema design
- Use of **primary keys**, **foreign keys**, **unique constraints**, and **check constraints**
- Implementation of **One-to-One**, **One-to-Many**, and **Many-to-Many** relationships
- Support for billing and insurance records

---

## 🏗️ Database Schema
The main entities include:

- **roles** – defines system roles (Doctor, Nurse, Admin, Reception)  
- **staff** – employees of the clinic  
- **doctors** – doctor-specific details (specialty, license, years of experience)  
- **clinics** – clinic branches  
- **patients** – registered patients  
- **patient_profiles** – extended patient info (blood type, emergency contact)  
- **allergies** + **patient_allergies** – many-to-many relationship  
- **rooms** – consultation rooms  
- **appointments** – bookings between patients and doctors  
- **diagnoses** – medical diagnoses per appointment  
- **medications** – medication master list  
- **prescriptions** + **prescription_medications** – prescriptions with drugs  
- **insurance_providers** + **patient_insurance** – insurance coverage details  
- **bills** + **payments** – billing and payment tracking  

---

## 🔗 Relationships
- **One-to-One**:  
  - `patients` ↔ `patient_profiles`  
  - `staff` ↔ `doctors`  

- **One-to-Many**:  
  - `patients` → `appointments`  
  - `doctors` → `appointments`  
  - `appointments` → `diagnoses`  
  - `appointments` → `bills`  

- **Many-to-Many**:  
  - `patients` ↔ `allergies`  
  - `prescriptions` ↔ `medications`  

---

## ⚙️ Installation

### 1. Clone Repository
```bash
git clone https://github.com/hhijo/plp-DBMS-clinic-management.git
cd plp-DBMS-clinic-management
