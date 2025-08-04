import ballerina/sql;
import ballerina/log;
import ballerinax/ibm.ibmmq;

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

public function sendMessageToQueue() returns error? {
    ibmmq:Queue queue = check queueManager.accessQueue(queueName, ibmmq:MQOO_OUTPUT);
    string payloadString = "{\n" +
        "    \"appointmentId\": \"APT001\",\n" +
        "    \"patient\": {\n" +
        "        \"patientId\": \"PAT002\",\n" +
        "        \"patientName\": \"Amy Williams\",\n" +
        "        \"patientEmail\": \"amy.williams@gmail.com\",\n" +
        "        \"patientPhoneNumber\": \"+1-555-123-4567\"\n" +
        "    },\n" +
        "    \"doctor\": {\n" +
        "        \"doctorId\": \"DOC002\",\n" +
        "        \"doctorName\": \"Rafael Costa\",\n" +
        "        \"specialization\": \"Cardiology\"\n" +
        "    },\n" +
        "    \"hospital\": \"Green Valley Hospital\",\n" +
        "    \"appointmentTime\": \"2025-08-15 10:30:00\",\n" +
        "    \"status\": \"scheduled\",\n" +
        "    \"notes\": \"Patient reported occasional chest pain. Follow-up required.\"\n" +
        "}";

    ibmmq:Message message = { payload: payloadString.toBytes() };
    check queue->put(message);
    check queue->close();
    log:printInfo("Message sent to the queue! :)");
    return;
}

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

public function scheduleAppointment(Appointment appointment) returns error? {
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

public function insertAppointment(Appointment appointment) returns error? {
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
        log:printInfo("Appointment inserted successfully with ID: " + appointment.appointmentId);
        return;
    }
}