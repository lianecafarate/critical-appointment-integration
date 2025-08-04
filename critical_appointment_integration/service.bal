import ballerinax/ibm.ibmmq;
import ballerina/log;

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
    sessionAckMode: "CLIENT_ACKNOWLEDGE",
    pollingInterval
}

service on ibmmqListener {
    remote function onMessage(ibmmq:Message message, ibmmq:Caller caller) returns error? {
        string payloadString = check string:fromBytes(message.payload);
        log:printInfo("Received message from IBM MQ", message = payloadString);

        json payloadJson = check payloadString.fromJsonString();
        Appointment appointment = check payloadJson.cloneWithType(Appointment);
        log:printInfo("Processing appointment", appointment = appointment);

        // Schedule appointment and handle errors
        error? scheduleResult = scheduleAppointment(appointment);
        if scheduleResult is error {
            log:printError("Error scheduling appointment: " + scheduleResult.message());
            return scheduleResult; // Exit before acknowledgment
        } else {
            // Use trap to catch error without failing
            error? ackErr = caller->acknowledge(message);
            if ackErr is error {
                log:printError("Failed to acknowledge message: " + ackErr.message());
            } else {
                log:printInfo("Message acknowledged successfully.");
            }
        }
    }
}