import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/http;

type RentalRequest record {
    string consumer_id;
    string property_id;
    string rental_start_date;
    int rental_duration_days;
    string payment_method;
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;


public function main() returns error? {

mysql:Client dbClient = check new (user = USER, password = PASSWORD, database = DATABASE, host = HOST, port = PORT);

    // Define the SQL query
    sql:ParameterizedQuery query = `SELECT consumer_id, property_id, rental_start_date, rental_duration_days, payment_method FROM rentals`;

    // Execute the SQL query
    stream<RentalRequest, sql:Error?> resultStream =  dbClient->query(query);

    // Iterate through the result stream
    check from RentalRequest rentalRequest in resultStream
        do {
            log:printInfo("Rental Request: " + rentalRequest.toString());

            // Call the endpoint
            http:Client clientEndpoint = check new ("https://d52b01c3-4413-4648-aa17-45f6070d28b4-dev.e1-eu-north-azure.choreoapis.dev");
            http:Response response = check clientEndpoint->post("/supply-chain/rental-integration-servic/v1/process", rentalRequest);



        };



}
