import ballerina/log;
import ballerina/io;
import ballerinax/ibm.ibmmq;

public function main() returns error? {
    io:println("Appointment Service is starting...");

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
}