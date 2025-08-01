// Patient information record
public type Patient record {|
    string patientId;
    string patientName;
    string patientEmail;
    string patientPhoneNumber?;
|};

// Doctor information record
public type Doctor record {|
    string doctorId;
    string doctorName;
    string specialization?;
|};


// Appointment record
public type Appointment record {|
    string appointmentId;
    Patient patient;
    Doctor doctor;
    string hospital;
    //YYYY-MM-DD hh:mm:ss
    string appointmentTime;
    string status?;
    string notes?;
|};