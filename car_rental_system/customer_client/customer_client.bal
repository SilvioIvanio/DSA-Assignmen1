import ballerina/grpc;
import ballerina/io;

string currentUserId = "";

public function main() returns error? {

    CarRentalServiceClient carClient = check new ("http://localhost:9090");

    //  Customer Menu 
    while true {
        io:println("\n CUSTOMER MENU ");
        io:println("1. List available cars");
        io:println("2. Search car by plate");
        io:println("3. Add car to cart");
        io:println("4. Place reservation");
        io:println("5. Exit");

        string choice = io:readln("Select option: ");

        match choice {
            "1" => { check listAvailableCars(carClient); }
            "2" => { check searchCar(carClient); }
            "3" => { check addToCart(carClient); }
            "4" => { check placeReservation(carClient); }
            "5" => {
                io:println("Thank you for using our service!");
                return;
            }
            _ => { io:println("Invalid choice!"); }
        }
    }
}

//Customer Operations 

function listAvailableCars(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- AVAILABLE CARS ---");
    string filter = io:readln("Enter filter (or press Enter for all): ");

    stream<Car, grpc:Error?> carStream = check carClient->list_available_cars({filter: filter});
    int count = 0;

    check from Car car in carStream
        do {
            count += 1;
            io:println("\n", count.toString(), ". ", car.make, " ", car.model, " (", car.year.toString(), ")");
            io:println("   Plate: ", car.plate);
            io:println("   Daily Price: N$", car.daily_price.toString());
            io:println("   Mileage: ", car.mileage.toString(), " km");
        };

    if count == 0 {
        io:println("No available cars found.");
    }
}
