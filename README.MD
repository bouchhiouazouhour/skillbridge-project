# CV Optimizer – Frontend & Backend Technical Summary

This document provides a clear and concise overview of the **Flutter frontend** and **Laravel + PostgreSQL backend** currently implemented for the CV Optimizer app. It is designed so all team members (design, backend, frontend, QA) understand the state of the project.

---

## **1. Frontend (Flutter) Summary**

The mobile frontend is built using **Flutter**, targeting both Android and iOS.

### **1.1 Purpose of the Screen**

The current view collects the user’s basic information such as:

* CV file upload (PDF, DOC, DOCX)
* Full name
* Current city
* Country code + phone number
* Preferred payment method

This data will later be submitted to the backend for processing.

---

## **1.2 UI Behavior Overview**

### **File Upload Component**

* Uses `file_picker` package.
* Accepts **PDF, DOC, DOCX**.
* Displays the file name once selected.
* Box uses light grey (`Colors.grey.shade200`) with a soft border.

### **Text Inputs**

* All inputs share a consistent style:

  * Filled light grey background
  * Rounded corners (8px)
  * Smooth grey outline
  * Focused state: slightly darker grey

### **Phone Input**

* Custom input combining:

  * Country code dropdown (e.g., +1, +216, +33, +971)
  * Phone number field
* Styled inside a single container so it appears as one UI component.

### **Preferred Payment Method**

* Dropdown with options:

  * Credit Card
  * Debit Card
  * PayPal
  * Bank Transfer

### **Navigation**

* Bottom navigation bar with 4 icons (no labels).
* Colors match the rest of the app theme.

### **Next Button**

* Black button, white text
* Rounded corners

---

## **1.3 Pending Frontend Tasks**

* Integrate form submission call to API (multipart request).
* Error states & validation (visual).
* Optional: show upload progress / success animation.
* Optional: move to a multi-step form.

---

# **2. Backend (Laravel + PostgreSQL) Summary**

Backend is fully prepared to receive user submissions and store uploaded CVs.

## **2.1 Technology Stack**

* **Laravel** (API-only mode)
* **PostgreSQL** database
* **Laravel Filesystem** for file storage
* Optional: **Laravel Sanctum** for authentication

---

## **2.2 Main Features Implemented**

Backend currently supports:

### **✔ CV Upload Endpoint**

Route: `POST /api/resumes`

The endpoint handles:

* Validating all fields
* Validating & storing uploaded file
* Saving metadata + form fields to database
* Returning structured JSON

### **✔ File Storage**

* Uses Laravel’s filesystem (`public` or `s3`)
* Files are stored under `resumes/` folder
* File names are uniquely generated

### **✔ Database Schema**

A `resumes` table containing:

* User fields (name, city, phone, payment)
* File metadata (file name, path, size, MIME type)
* Timestamp fields

---

## **2.3 API Validation Rules**

The backend ensures:

* `full_name` is required
* CV file is required and must be PDF/DOC/DOCX
* Max file size: 10MB
* `payment_method` must be one of the supported types

This prevents malformed or dangerous data from entering the system.

---

## **2.4 JSON Response Example**

```
{
  "message": "Resume uploaded successfully",
  "data": {
    "id": 12,
    "full_name": "John Doe",
    "file_name": "CV.pdf",
    "file_path": "resumes/12345_CV.pdf",
    "mime_type": "application/pdf",
    "file_size": 204833,
    "created_at": "2025-02-14T12:33:21Z"
  }
}
```

---

# **3. How Frontend Submits to Backend**

The Flutter app will submit using a **multipart/form-data request**.

Fields sent:

* `full_name`
* `current_city`
* `country_code`
* `phone_number`
* `payment_method`
* `cv` (file)

Backend stores everything in database + storage.

---

# **4. Next Steps for Integration**

### **Frontend**

* Add API call using the provided Flutter service code
* Show loading state when uploading
* Display errors returned from backend

### **Backend**

* Add optional authentication (if needed later)
* Add job queue for CV processing (AI, text extraction, etc.)
* Add admin panel (optional)

---

# **5. Summary for the Team**

* **Frontend**: Full UI for the form is complete; file picker and styling are consistent. Needs API integration next.
* **Backend**: Upload endpoint, validation, database, and file handling are complete. Ready for frontend use.
* **Objective**: Seamlessly send user form + CV file from Flutter → Laravel → PostgreSQL.

This document should help all team members stay aligned as we continue building the project.
