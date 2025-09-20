-- clinic_db.sql
-- Clinic Booking & Management System

-- DROP DATABASE if exists (uncomment to reset)
-- DROP DATABASE IF EXISTS clinic_management;

CREATE DATABASE IF NOT EXISTS clinic_management
  DEFAULT CHARACTER SET = utf8mb4
  DEFAULT COLLATE = utf8mb4_general_ci;
USE clinic_management;

-- ===========================
-- Table: roles (system user roles)
-- ===========================
CREATE TABLE roles (
  role_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255)
) ENGINE=InnoDB;

-- ===========================
-- Table: staff (doctors, nurses, admin)
-- ===========================
CREATE TABLE staff (
  staff_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id INT UNSIGNED NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_staff_email (email),
  CONSTRAINT fk_staff_role FOREIGN KEY (role_id)
    REFERENCES roles(role_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: clinics (one or more branches)
-- ===========================
CREATE TABLE clinics (
  clinic_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  address VARCHAR(255),
  phone VARCHAR(20),
  UNIQUE (name)
) ENGINE=InnoDB;

-- ===========================
-- Table: doctors (specialized info, one-to-one with staff)
-- One-to-One relationship with staff: each doctor is a staff member
-- ===========================
CREATE TABLE doctors (
  doctor_id INT UNSIGNED PRIMARY KEY, -- will be same value as staff.staff_id
  clinic_id INT UNSIGNED NOT NULL,
  speciality VARCHAR(100),
  license_number VARCHAR(100) NOT NULL UNIQUE,
  years_experience TINYINT UNSIGNED DEFAULT 0,
  CONSTRAINT fk_doctor_staff FOREIGN KEY (doctor_id)
    REFERENCES staff(staff_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_doctor_clinic FOREIGN KEY (clinic_id)
    REFERENCES clinics(clinic_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: patients
-- ===========================
CREATE TABLE patients (
  patient_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender ENUM('Male','Female','Other') DEFAULT 'Other',
  national_id VARCHAR(50) UNIQUE, -- optional national identifier
  email VARCHAR(150),
  phone VARCHAR(20),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_patient_nationalid (national_id)
) ENGINE=InnoDB;

-- ===========================
-- Table: patient_profiles (one-to-one extra info)
-- One-to-One: primary key is patient_id and FK to patients
-- ===========================
CREATE TABLE patient_profiles (
  patient_id INT UNSIGNED PRIMARY KEY,
  blood_type ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') DEFAULT NULL,
  height_cm SMALLINT UNSIGNED,
  weight_kg SMALLINT UNSIGNED,
  emergency_contact_name VARCHAR(150),
  emergency_contact_phone VARCHAR(20),
  CONSTRAINT fk_profile_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: allergies (master list)
-- ===========================
CREATE TABLE allergies (
  allergy_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(255)
) ENGINE=InnoDB;

-- ===========================
-- Table: patient_allergies (many-to-many: patients <-> allergies)
-- ===========================
CREATE TABLE patient_allergies (
  patient_id INT UNSIGNED NOT NULL,
  allergy_id INT UNSIGNED NOT NULL,
  noted_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  severity ENUM('Mild','Moderate','Severe') DEFAULT 'Moderate',
  PRIMARY KEY (patient_id, allergy_id),
  CONSTRAINT fk_pa_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_pa_allergy FOREIGN KEY (allergy_id)
    REFERENCES allergies(allergy_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: rooms (clinic rooms / consultation rooms)
-- ===========================
CREATE TABLE rooms (
  room_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clinic_id INT UNSIGNED NOT NULL,
  room_number VARCHAR(50) NOT NULL,
  floor TINYINT,
  UNIQUE KEY uq_room_clinic (clinic_id, room_number),
  CONSTRAINT fk_room_clinic FOREIGN KEY (clinic_id)
    REFERENCES clinics(clinic_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: appointments
-- One-to-Many: patient -> appointments, doctor -> appointments
-- ===========================
CREATE TABLE appointments (
  appointment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  patient_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED NOT NULL, -- references doctors.doctor_id (== staff_id)
  clinic_id INT UNSIGNED NOT NULL,
  room_id INT UNSIGNED,
  scheduled_start DATETIME NOT NULL,
  scheduled_end DATETIME NOT NULL,
  status ENUM('Scheduled','Checked-in','Completed','Cancelled','No-show') NOT NULL DEFAULT 'Scheduled',
  reason VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_time CHECK (scheduled_end > scheduled_start),
  CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id)
    REFERENCES doctors(doctor_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_appt_clinic FOREIGN KEY (clinic_id)
    REFERENCES clinics(clinic_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_appt_room FOREIGN KEY (room_id)
    REFERENCES rooms(room_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  INDEX idx_appt_doctor_start (doctor_id, scheduled_start),
  INDEX idx_appt_patient_start (patient_id, scheduled_start)
) ENGINE=InnoDB;

-- ===========================
-- Table: diagnoses (one appointment can have many diagnoses)
-- ===========================
CREATE TABLE diagnoses (
  diagnosis_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id BIGINT UNSIGNED NOT NULL,
  icd10_code VARCHAR(20),
  description VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_diag_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: medications (master list)
-- ===========================
CREATE TABLE medications (
  medication_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  manufacturer VARCHAR(150),
  unit VARCHAR(50) DEFAULT 'tablet',
  UNIQUE (name)
) ENGINE=InnoDB;

-- ===========================
-- Table: prescriptions
-- A prescription is issued for an appointment
-- ===========================
CREATE TABLE prescriptions (
  prescription_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id BIGINT UNSIGNED NOT NULL,
  issued_by INT UNSIGNED NOT NULL, -- staff_id (doctor)
  issued_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  notes TEXT,
  CONSTRAINT fk_presc_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_presc_issued_by FOREIGN KEY (issued_by)
    REFERENCES staff(staff_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: prescription_medications (many-to-many between prescriptions and medications)
-- ===========================
CREATE TABLE prescription_medications (
  prescription_id BIGINT UNSIGNED NOT NULL,
  medication_id INT UNSIGNED NOT NULL,
  dosage VARCHAR(100) NOT NULL, -- e.g., "500 mg"
  frequency VARCHAR(100) NOT NULL, -- e.g., "Twice daily"
  duration_days SMALLINT UNSIGNED,
  PRIMARY KEY (prescription_id, medication_id),
  CONSTRAINT fk_pm_prescription FOREIGN KEY (prescription_id)
    REFERENCES prescriptions(prescription_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_pm_medication FOREIGN KEY (medication_id)
    REFERENCES medications(medication_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: insurance_providers
-- ===========================
CREATE TABLE insurance_providers (
  provider_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE,
  contact_phone VARCHAR(20),
  address VARCHAR(255)
) ENGINE=InnoDB;

-- ===========================
-- Table: patient_insurance (one patient may have many policies)
-- ===========================
CREATE TABLE patient_insurance (
  policy_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  patient_id INT UNSIGNED NOT NULL,
  provider_id INT UNSIGNED NOT NULL,
  policy_number VARCHAR(150) NOT NULL,
  valid_from DATE NOT NULL,
  valid_to DATE NOT NULL,
  CONSTRAINT fk_pi_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_pi_provider FOREIGN KEY (provider_id)
    REFERENCES insurance_providers(provider_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT chk_policy_dates CHECK (valid_to > valid_from)
) ENGINE=InnoDB;

-- ===========================
-- Table: bills (billing per appointment)
-- ===========================
CREATE TABLE bills (
  bill_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id BIGINT UNSIGNED NOT NULL UNIQUE, -- one bill per appointment
  patient_id INT UNSIGNED NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  insurance_covered_amount DECIMAL(10,2) DEFAULT 0.00,
  patient_due_amount DECIMAL(10,2) AS (total_amount - insurance_covered_amount) STORED,
  status ENUM('Unpaid','Partially Paid','Paid','Voided') NOT NULL DEFAULT 'Unpaid',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bill_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_bill_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Table: payments (could be multiple payments per bill)
-- ===========================
CREATE TABLE payments (
  payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  bill_id BIGINT UNSIGNED NOT NULL,
  paid_by VARCHAR(150), -- patient's name or insurance
  amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  method ENUM('Cash','Card','Mobile Money','Insurance','Other') DEFAULT 'Cash',
  paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_bill FOREIGN KEY (bill_id)
    REFERENCES bills(bill_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===========================
-- Useful sample seed data for roles 
-- ===========================
INSERT IGNORE INTO roles (role_name, description) VALUES
  ('Doctor', 'Licensed medical doctor'),
  ('Nurse', 'Registered nurse'),
  ('Admin', 'Administrative staff'),
  ('Reception', 'Front desk/reception staff');

-- A few optional indexes to speed common queries
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_patients_name ON patients(last_name, first_name);

-- End of schema
