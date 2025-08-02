# Critical Appointment Integration

This project demonstrates a **message-processing integration** using **Ballerina** and **IBM MQ** to handle **critical appointment data** reliably. 

## 📌 Use Case Overview
- **Source:** IBM MQ
- **Processing Logic:** Ballerina Service
- **Destination:** Relational Database (MySQL)

## 🚀 Features
- **Database Integration:** Persists appointment records in a relational database (e.g., MySQL).
- **Comprehensive Logging:** Logs message receipt, processing steps, DB status, and error traces.
- **Configuration Management:** Supports flexible connection settings via `Config.bal`.
- **Need to add more!**

## 🏗 Architecture

The system consists of the following components:

- **JMS Listener:** A Ballerina service that listens to `APPOINTMENT.QUEUE` on IBM MQ.
- **Appointment Processing:** Ballerina code validates and transforms the data.
- **Database Layer:** Uses MySQL to persist the appointment data.
- **Configuration Management:** Configurable database and IBM MQ settings.
- **Logging:** Comprehensive logging for all operations.

## 🗃 Database Schema

The system expects the following MySQL tables, defined under the database **blueriver**. You can find the full SQL script in the db-scripts folder.

- **patient:** Stores patient details including name, email, and phone number.
- **doctor:** Contains doctor information such as name and specialization.
- **appointment:** Stores critical appointment data with links to both patient and doctor, including time, hospital, status, and notes.

## 🛠 Technologies Used
- [Ballerina Swan Lake](https://ballerina.io/downloads/) (latest version)
- [IBM MQ](https://www.ibm.com/products/mq) (Version 9.4.1.0)
- [MySQL](https://www.mysql.com/) (Version 8.4.0)
- [Rancher Desktop](https://rancherdesktop.io/) (laterst version)

## ⚙️Setup
1. Clone the repository
2. Set up your MySQL database with the required schema
3. Configure your **config.bal** file with the needed variables
4. Add dependencies to the **Ballerina.toml** file
5. Run the command: bal build (Or use the [VSCode Ballerina Extension](https://ballerina.io/learn/vs-code-extension/)

## 🚫 Security Disclaimer
This project is intended for learning, prototyping, and internal demonstration purposes only. It is not production-ready and lacks several security best practices required for deployment in real-world environments.

### ⚠️ Known Security Limitations:
- Credentials (e.g., database, MQ) are stored in plaintext in configuration files.
- No authentication or authorization is implemented for internal services.
- No encryption (TLS) is enabled for communication between components.
- No input validation or sanitization is enforced.
- Logs may expose sensitive information in plaintext. 


