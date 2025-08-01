import ballerinax/ibm.ibmmq;
import ballerina/log;
import ballerina/sql;

// ===== IBM MQ Integration =====
listener ibmmq:Listener ibmmqListener = check new({
    name: queueManagerName,
    host: queueHost,
    port: queuePort,
    channel: queueChannel,
    userID: queueUserID,
    password: queuePassword
});

@ibmmq:ServiceConfig {
    queueName,
    pollingInterval
}

service on ibmmqListener { 
    remote function onMessage(ibmmq:Message message) returns error? {
        // Handle incoming messages from the IBM MQ
        log:printInfo("Received message from IBM MQ: ", message = check string:fromBytes(message.payload));
        
        // Extract and parse the payload from the IBM MQ message
        string payloadString = check string:fromBytes(message.payload);
        json payloadJson = check payloadString.fromJsonString();

        // Convert the JSON payload to Appointment record
        Appointment appointment = check payloadJson.cloneWithType(Appointment);
        log:printInfo("Processing appointment: ", appointment = appointment);

        // Schedule the appointment
        string|sql:Error? result = scheduleAppointment(appointment);
        if result is string {
            log:printInfo(result);
        } else if result is sql:Error {
            log:printError("Error scheduling appointment: " + result.message());
        } else {
            log:printInfo("Appointment scheduled successfully: " + appointment.appointmentId);
        }
    }
}