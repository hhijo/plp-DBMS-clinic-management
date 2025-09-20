-- ===========================
-- Sample seed data
-- ===========================

-- Clinics
INSERT INTO clinics (name, address, phone) VALUES
('Downtown Clinic', '123 Health St, Nairobi', '0700111222'),
('Westside Clinic', '45 Wellness Ave, Nakuru', '0700333444');

-- Staff
INSERT INTO staff (role_id, first_name, last_name, email, phone)
VALUES
(1, 'Alice', 'Kamau', 'alice.kamau@clinic.com', '0711222333'), -- doctor
(2, 'Peter', 'Otieno', 'peter.otieno@clinic.com', '0711444555'), -- nurse
(3, 'Mary', 'Njoki', 'mary.njoki@clinic.com', '0711666777'); -- admin

-- Doctors (linking staff_id=1 as a doctor)
INSERT INTO doctors (doctor_id, clinic_id, speciality, license_number, years_experience)
VALUES (1, 1, 'Pediatrics', 'DOC-KE-2025-001', 8);

-- Patients
INSERT INTO patients (first_name, last_name, date_of_birth, gender, national_id, email, phone)
VALUES
('John', 'Mwangi', '1990-04-12', 'Male', '12345678', 'john.mwangi@email.com', '0722000111'),
('Grace', 'Achieng', '2000-09-15', 'Female', '87654321', 'grace.achieng@email.com', '0722333444');

-- Patient profiles
INSERT INTO patient_profiles (patient_id, blood_type, height_cm, weight_kg, emergency_contact_name, emergency_contact_phone)
VALUES
(1, 'O+', 175, 70, 'Jane Mwangi', '0712345678'),
(2, 'A-', 160, 55, 'Paul Achieng', '0799888777');

-- Allergies
INSERT INTO allergies (name, description) VALUES
('Penicillin', 'Allergic reaction to Penicillin'),
('Peanuts', 'Peanut allergy');

-- Patient allergies
INSERT INTO patient_allergies (patient_id, allergy_id, severity)
VALUES
(1, 1, 'Severe'),
(2, 2, 'Moderate');

-- Rooms
INSERT INTO rooms (clinic_id, room_number, floor) VALUES
(1, '101', 1),
(1, '102', 1);

-- Appointments
INSERT INTO appointments (patient_id, doctor_id, clinic_id, room_id, scheduled_start, scheduled_end, status, reason)
VALUES
(1, 1, 1, 1, '2025-09-22 09:00:00', '2025-09-22 09:30:00', 'Scheduled', 'Routine Checkup'),
(2, 1, 1, 2, '2025-09-22 10:00:00', '2025-09-22 10:30:00', 'Scheduled', 'Fever and headache');

-- Diagnoses
INSERT INTO diagnoses (appointment_id, icd10_code, description)
VALUES
(1, 'Z00.0', 'General medical examination'),
(2, 'J06.9', 'Acute upper respiratory infection');

-- Medications
INSERT INTO medications (name, manufacturer, unit)
VALUES
('Paracetamol', 'MediPharm', 'tablet'),
('Amoxicillin', 'PharmaPlus', 'capsule');

-- Prescriptions
INSERT INTO prescriptions (appointment_id, issued_by, notes)
VALUES
(2, 1, 'Prescribed antibiotics and rest');

-- Prescription medications
INSERT INTO prescription_medications (prescription_id, medication_id, dosage, frequency, duration_days)
VALUES
(1, 2, '500mg', 'Twice daily', 7);

-- Insurance providers
INSERT INTO insurance_providers (name, contact_phone, address)
VALUES
('NHIF', '0800720600', 'Community Health House, Nairobi');

-- Patient insurance
INSERT INTO patient_insurance (patient_id, provider_id, policy_number, valid_from, valid_to)
VALUES
(1, 1, 'NHIF-12345', '2025-01-01', '2025-12-31');

-- Bills
INSERT INTO bills (appointment_id, patient_id, total_amount, insurance_covered_amount, status)
VALUES
(1, 1, 5000.00, 4000.00, 'Partially Paid'),
(2, 2, 3000.00, 0.00, 'Unpaid');

-- Payments
INSERT INTO payments (bill_id, paid_by, amount, method)
VALUES
(1, 'NHIF', 4000.00, 'Insurance'),
(1, 'John Mwangi', 1000.00, 'Mobile Money');
