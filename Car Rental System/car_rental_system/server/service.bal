import ballerina/grpc;
import ballerina/log;
import ballerina/uuid;
import ballerina/time;
import ballerina/regex;

// In-memory storage
map<Car> cars = {};
map<User> users = {};
map<CartItem[]> userCarts = {};
map<Reservation> reservations = {};

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

     // Add a new car to the system
    remote function add_car(AddCarRequest request) returns AddCarResponse|error {
        Car car = request.car;
        
        // Check if car already exists
        if cars.hasKey(car.plate) {
            return {
                plate: car.plate,
                message: "Car with this plate already exists"
            };
        }
        
        // Add car to storage
        cars[car.plate] = car;
        
        log:printInfo("Car added: " + car.plate);
        return {
            plate: car.plate,
            message: "Car successfully added to the system"
        };
    }
    
    // Create multiple users (client streaming)
    remote function create_users(stream<User, grpc:Error?> clientStream) 
                                returns CreateUsersResponse|error {
        int userCount = 0;
        
        check from User user in clientStream
            do {
                users[user.user_id] = user;
                userCount += 1;
                log:printInfo("User created: " + user.user_id);
            };
        
        return {
            users_created: userCount,
            message: userCount.toString() + " users successfully created"
        };
    }
    
    // Update car details
    remote function update_car(UpdateCarRequest request) returns UpdateCarResponse|error {
        string plate = request.plate;
        
        if !cars.hasKey(plate) {
            return {
                success: false,
                message: "Car not found with plate: " + plate
            };
        }
        
        Car updatedCar = request.updated_car;
        updatedCar.plate = plate; // Ensure plate doesn't change
        cars[plate] = updatedCar;
        
        log:printInfo("Car updated: " + plate);
        return {
            success: true,
            message: "Car successfully updated"
        };
    }
    
    // Remove a car from the system
    remote function remove_car(RemoveCarRequest request) returns RemoveCarResponse|error {
        string plate = request.plate;
        
        if !cars.hasKey(plate) {
            return {
                cars: cars.toArray(),
                message: "Car not found with plate: " + plate
            };
        }
        
        _ = cars.remove(plate);
        log:printInfo("Car removed: " + plate);
        
        return {
            cars: cars.toArray(),
            message: "Car successfully removed. Updated car list returned."
        };
    }
    
    // List available cars (server streaming)
    remote function list_available_cars(ListAvailableCarsRequest request) 
                                returns stream<Car, error?>|error {
        Car[] availableCars = [];
        string filter = request.filter.toLowerAscii();
        
        foreach Car car in cars {
            if car.status == AVAILABLE {
                if filter == "" {
                    availableCars.push(car);
                } else {
                    // Apply filter
                    string carInfo = (car.make + " " + car.model + " " + car.year.toString()).toLowerAscii();
                    if carInfo.includes(filter) {
                        availableCars.push(car);
                    }
                }
            }
        }
        
        return availableCars.toStream();
    }

    // List all reservations (server streaming)
remote function list_reservations(Empty request) returns stream<Reservation, error?>|error {
    Reservation[] allReservations = [];
    foreach Reservation res in reservations {
        allReservations.push(res);
    }
    return allReservations.toStream();
}
    
    // Search for a specific car by plate
    remote function search_car(SearchCarRequest request) returns SearchCarResponse|error {
        string plate = request.plate;
        
        if cars.hasKey(plate) {
            Car car = cars.get(plate);
            if car.status == AVAILABLE {
                return {
                    car: car,
                    found: true,
                    message: "Car found and available"
                };
            } else {
                return {
                    car: car,
                    found: true,
                    message: "Car found but not available"
                };
            }
        }
        
        return {
            car: {},
            found: false,
            message: "Car not found with plate: " + plate
        };
    }
    
    // Add car to user's cart
    remote function add_to_cart(AddToCartRequest request) returns AddToCartResponse|error {
        string userId = request.user_id;
        string plate = request.plate;
        string startDate = request.start_date;
        string endDate = request.end_date;
        
        // Validate car exists
        if !cars.hasKey(plate) {
            return {
                success: false,
                message: "Car not found with plate: " + plate
            };
        }
        
        // Validate dates
        if !isValidDateFormat(startDate) || !isValidDateFormat(endDate) {
            return {
                success: false,
                message: "Invalid date format. Use DD-MM-YYYY"
            };
        }
        
        // Check if dates make sense
        if !areDatesValid(startDate, endDate) {
            return {
                success: false,
                message: "End date must be after start date"
            };
        }
        
        // Add to cart
        CartItem cartItem = {
            plate: plate,
            start_date: startDate,
            end_date: endDate
        };
        
        if userCarts.hasKey(userId) {
            CartItem[] cart = userCarts.get(userId);
            cart.push(cartItem);
            userCarts[userId] = cart;
        } else {
            userCarts[userId] = [cartItem];
        }
        
        log:printInfo("Added to cart for user: " + userId);
        return {
            success: true,
            message: "Car added to cart successfully"
        };
    }
    
    // Place reservation from cart
    remote function place_reservation(PlaceReservationRequest request) 
                                    returns PlaceReservationResponse|error {
        string userId = request.user_id;
        
        if !userCarts.hasKey(userId) {
            return {
                reservation: {},
                success: false,
                message: "Cart is empty"
            };
        }
        
        CartItem[] cart = userCarts.get(userId);
        if cart.length() == 0 {
            return {
                reservation: {},
                success: false,
                message: "Cart is empty"
            };
        }
        
        // Calculate total price
        float totalPrice = 0.0;
        foreach CartItem item in cart {
            if cars.hasKey(item.plate) {
                Car car = cars.get(item.plate);
                int days = calculateDays(item.start_date, item.end_date);
                totalPrice += car.daily_price * <float>days;
            }
        }
        
        // Create reservation
        string reservationId = uuid:createType1AsString();
        Reservation reservation = {
            reservation_id: reservationId,
            user_id: userId,
            items: cart,
            total_price: totalPrice,
            reservation_date: getCurrentDate()
        };
        
        reservations[reservationId] = reservation;
        
        // Clear cart
        userCarts[userId] = [];
        
        log:printInfo("Reservation placed: " + reservationId);
        return {
            reservation: reservation,
            success: true,
            message: "Reservation successfully placed"
        };
    }
}

// Helper functions
function isValidDateFormat(string date) returns boolean {
    string:RegExp datePattern = re `^\d{2}-\d{2}-\d{4}$`;
    return datePattern.isFullMatch(date);
}

function areDatesValid(string startDate, string endDate) returns boolean {
    // Simple comparison (in real app, use proper date parsing)
    string[] startParts = regex:split(startDate, "-");
    string[] endParts = regex:split(endDate, "-");
    
    int startYear = checkpanic int:fromString(startParts[2]);
    int startMonth = checkpanic int:fromString(startParts[1]);
    int startDay = checkpanic int:fromString(startParts[0]);
    
    int endYear = checkpanic int:fromString(endParts[2]);
    int endMonth = checkpanic int:fromString(endParts[1]);
    int endDay = checkpanic int:fromString(endParts[0]);
    
    if endYear > startYear {
        return true;
    } else if endYear == startYear {
        if endMonth > startMonth {
            return true;
        } else if endMonth == startMonth {
            return endDay >= startDay;
        }
    }
    return false;
}

function calculateDays(string startDate, string endDate) returns int {
    // Simplified calculation (in real app, use proper date library)
    string[] startParts = regex:split(startDate, "-");
    string[] endParts = regex:split(endDate, "-");
    
    int startDay = checkpanic int:fromString(startParts[0]);
    int endDay = checkpanic int:fromString(endParts[0]);
    
    // Simple calculation (assuming same month for simplicity)
    int days = endDay - startDay + 1;
    return days > 0 ? days : 1;
}

function getCurrentDate() returns string {
    time:Utc currentTime = time:utcNow();
    time:Civil civil = time:utcToCivil(currentTime);
    return civil.day.toString() + "-" + civil.month.toString() + "-" + civil.year.toString();
}