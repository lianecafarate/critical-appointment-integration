import ballerinax/ibm.ibmmq;
import ballerina/log;

//IBM MQ Listener creation
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
    sessionAckMode: ibmmq:SESSION_TRANSACTED,
    pollingInterval
}

//Service to handle incoming messages from IBM MQ
service on ibmmqListener {
    remote function onMessage(ibmmq:Message message, ibmmq:Caller caller) returns error? {
        string payloadString = check string:fromBytes(message.payload);
        log:printInfo("Received message from IBM MQ", message = payloadString);

        json payloadJson = check payloadString.fromJsonString();
        Appointment appointment = check payloadJson.cloneWithType(Appointment);
        log:printInfo("Processing appointment", appointment = appointment);

        // Try to schedule the appointment
        error? scheduleResult = scheduleAppointment(appointment);
        if scheduleResult is error {
            log:printError("Error scheduling appointment: " + scheduleResult.message());
            check caller->'rollback(); // rollback the message so it can be redelivered
        } else {
            log:printInfo("Appointment scheduled successfully");
            check caller->'commit(); // acknowledge the message and commit the transaction
        }
    }
}