import ballerina/grpc;
import ballerina/io;

string currentUserId = "";

public function main() returns error? {

    CarRentalServiceClient carClient = check new ("http://localhost:9090");

    // ========== Customer Menu ==========
    while true {
        io:println("\n=== CUSTOMER MENU ===");
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

// ========== Customer Operations ==========

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

function searchCar(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- SEARCH CAR ---");
    string plate = io:readln("Enter plate number: ");

    SearchCarResponse response = check carClient->search_car({plate: plate});

    if response.found {
        io:println("\nCar found!");
        io:println("Make: ", response.car.make);
        io:println("Model: ", response.car.model);
        io:println("Year: ", response.car.year.toString());
        io:println("Daily Price: $", response.car.daily_price.toString());
        io:println("Status: ", response.car.status);
    } else {
        io:println("Car not found: ", response.message);
    }
}

function addToCart(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- ADD TO CART ---");
    string plate = io:readln("Enter car plate: ");
    string startDate = io:readln("Start date (DD-MM-YYYY): ");
    string endDate = io:readln("End date (DD-MM-YYYY): ");

    AddToCartResponse response = check carClient->add_to_cart({
        user_id: currentUserId,
        plate: plate,
        start_date: startDate,
        end_date: endDate
    });

    if response.success {
        io:println("Success: ", response.message);
    } else {
        io:println("Failed: ", response.message);
    }
}

function placeReservation(CarRentalServiceClient carClient) returns error? {
    io:println("\n--- PLACE RESERVATION ---");
    string confirm = io:readln("Confirm reservation from your cart? (y/n): ");

    if confirm.toLowerAscii() != "y" {
        io:println("Reservation cancelled.");
        return;
    }

    PlaceReservationResponse response = check carClient->place_reservation({
        user_id: currentUserId
    });

    if response.success {
        io:println("\n=== RESERVATION CONFIRMED ===");
        io:println("Reservation ID: ", response.reservation.reservation_id);
        io:println("Total Price: N$", response.reservation.total_price.toString());
        io:println("Date: ", response.reservation.reservation_date);
        io:println("\nItems:");
        foreach CartItem item in response.reservation.items {
            io:println("  - ", item.plate, " from ", item.start_date, " to ", item.end_date);
        }
    } else {
        io:println("Failed: ", response.message);
    }
}
