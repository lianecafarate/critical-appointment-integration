import ballerina/sql;
import ballerina/log;

// Define record type for appointment query results
type AppointmentRow record {|
    string appointmentId;
    string patientId;
    string doctorId;
    string hospital;
    string appointmentTime;
    string? status;
    string? notes;
|};

public function getAppointment(string appointmentId) returns string|AppointmentRow|sql:Error {
    sql:ParameterizedQuery selectQuery = `
        SELECT appointmentId, patientId, doctorId, hospital, appointmentTime, status, notes
        FROM appointment 
        WHERE appointmentId = ${appointmentId}
    `;
    
    var result = mysqlClient->queryRow(selectQuery, AppointmentRow);

    if result is AppointmentRow {
        // Appointment exists, return the Appointment record
        return result;
    } else if result is sql:NoRowsError {
        // No appointment found with this ID
        return string `Appointment with ID '${appointmentId}' does not exist`;
    } else {
        // This is an actual database error
        return result;
    }
}

public function scheduleAppointment(Appointment appointment) returns string|sql:Error? {
    log:printInfo("==Schedule Appointment Function==");
    // Check if the appointment already exists
    var existingAppointment = getAppointment(appointment.appointmentId);

    if existingAppointment is AppointmentRow {
        // Appointment already exists
        return error("Appointment with ID '" + appointment.appointmentId + "' already exists.");
    } else if existingAppointment is string {
        // Appointment does not exist (getAppointment returned string message), proceed to schedule
        log:printInfo("No existing appointment found, proceeding to insert new appointment.");
        return insertAppointment(appointment);
    } else {
        // Handle database error (remaining type is sql:Error)
        return error("Database error: " + existingAppointment.message());
    }
}

public function insertAppointment(Appointment appointment) returns string|sql:Error? {
    log:printInfo("==Insert Appointment Function==");
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO appointment (appointmentId, patientId, doctorId, hospital, appointmentTime, status, notes)
        VALUES (${appointment.appointmentId}, ${appointment.patient.patientId}, ${appointment.doctor.doctorId}, ${appointment.hospital}, 
                ${appointment.appointmentTime}, ${appointment.status}, ${appointment.notes})
    `;

    var result = mysqlClient->execute(insertQuery);

    if result is sql:Error {
        // Handle database error
        return error("Database error: " + result.message());
    } else {
        // Appointment inserted successfully
        return "Appointment inserted successfully with ID: " + appointment.appointmentId;
    }
}