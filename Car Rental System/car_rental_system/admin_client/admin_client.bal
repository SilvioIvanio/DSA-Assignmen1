import ballerina/grpc;
import ballerina/io;

string currentUserId = "";

public function main() returns error? {

    CarRentalServiceClient carClient = check new ("http://localhost:9090");

    // ========== Admin Menu ==========
    while true {
        io:println("\n=== ADMIN MENU ===");
        io:println("1. Add a new car");
        io:println("2. Update car details");
        io:println("3. Remove a car");
        io:println("4. List all reservations");
        io:println("5. Create users (batch)");
        io:println("6. Exit");

        string choice = io:readln("Select option: ");

        match choice {
            "1" => { check addCar(carClient); }
            "2" => { check updateCar(carClient); }
            "3" => { check removeCar(carClient); }
            "4" => { check listReservations(carClient); }
            "5" => { check createUsers(carClient); }
            "6" => {
                io:println("Goodbye!");
                return;
            }
            _ => { io:println("Invalid choice!"); }
        }
    }
}

// ========== Admin Operations ==========

function addCar(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- ADD NEW CAR ---");
    string make = io:readln("Make: ");
    string model = io:readln("Model: ");
    string yearStr = io:readln("Year: ");
    string priceStr = io:readln("Daily Price: ");
    string mileageStr = io:readln("Mileage: ");
    string plate = io:readln("Number Plate: ");

    Car newCar = {
        make: make,
        model: model,
        year: check int:fromString(yearStr),
        daily_price: check float:fromString(priceStr),
        mileage: check int:fromString(mileageStr),
        plate: plate,
        status: AVAILABLE
    };

    AddCarResponse response = check carClient->add_car({car: newCar});
    io:println("Result: ", response.message, " (plate=", response.plate, ")");
}

function updateCar(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- UPDATE CAR ---");
    string plate = io:readln("Enter plate number to update: ");

    io:println("Enter new details:");
    string make = io:readln("Make: ");
    string model = io:readln("Model: ");
    string yearStr = io:readln("Year: ");
    string priceStr = io:readln("Daily Price: ");
    string mileageStr = io:readln("Mileage: ");
    string statusChoice = io:readln("Status (1=Available, 2=Unavailable): ");

    CarStatus status = statusChoice == "2" ? UNAVAILABLE : AVAILABLE;

    Car updatedCar = {
        make: make,
        model: model,
        year: check int:fromString(yearStr),
        daily_price: check float:fromString(priceStr),
        mileage: check int:fromString(mileageStr),
        plate: plate,
        status: status
    };

    UpdateCarResponse response = check carClient->update_car({
        plate: plate,
        updated_car: updatedCar
    });

    if response.success {
        io:println("Success: ", response.message);
    } else {
        io:println("Failed: ", response.message);
    }
}

function removeCar(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- REMOVE CAR ---");
    string plate = io:readln("Enter plate number to remove: ");

    RemoveCarResponse response = check carClient->remove_car({plate: plate});
    io:println("Result: ", response.message);

    io:println("\nUpdated car list:");
    foreach Car car in response.cars {
        io:println("  - ", car.plate, ": ", car.make, " ", car.model);
    }
}

function listReservations(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- ALL RESERVATIONS ---");

    stream<Reservation, grpc:Error?> resStream = check carClient->list_reservations({});
    int count = 0;

    check from Reservation res in resStream
        do {
            count += 1;
            io:println("\nReservation #", count.toString());
            io:println("  ID: ", res.reservation_id);
            io:println("  User: ", res.user_id);
            io:println("  Total: $", res.total_price.toString());
            io:println("  Date: ", res.reservation_date);
            io:println("  Items:");
            foreach CartItem item in res.items {
                io:println("    - ", item.plate, " from ", item.start_date, " to ", item.end_date);
            }
        };

    if count == 0 {
        io:println("No reservations found.");
    }
}

function createUsers(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- CREATE USERS (BATCH) ---");
    string countStr = io:readln("How many users to create? ");
    int count = check int:fromString(countStr);

    // Client-streaming RPC
    Create_usersStreamingClient streamingClient = check carClient->create_users();

    int i = 0;
    while i < count {
        io:println("\nUser #", (i + 1).toString());
        string userId = io:readln("User ID: ");
        string name = io:readln("Name: ");
        string email = io:readln("Email: ");
        string roleChoice = io:readln("Role (1=Customer, 2=Admin): ");
        UserRole role = roleChoice == "2" ? ADMIN : CUSTOMER;

        check streamingClient->sendUser({
            user_id: userId,
            name: name,
            email: email,
            role: role
        });

        i += 1;
    }

    check streamingClient->complete();
    CreateUsersResponse? resp = check streamingClient->receiveCreateUsersResponse();

    if resp is CreateUsersResponse {
        io:println("\nResult: ", resp.message);
    }
}