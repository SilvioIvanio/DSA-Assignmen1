import ballerina/grpc; 
import ballerina/io;

type car record {
    readonly string number_plate;
    string make;
    string model;
    int year;
    float dailyPrice;
    int mileage;
    string status;
};

type user record {
    string id;
    string name;
    string userType;
};

type reservation record {
    string reservation_id;
    string user_id;
    string car_number_plate;
    string start_date;
    string end_date;
    float total_price;
    string status="available";
};

type cartItem record{
    string number_plate;
    string start_date;
    string end_date;
};

table<car> key(number_plate) cars = table [];
cartItem[] cart = [];
reservation[] reservations = [];
user[] users = [];

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
         car newCar = {
            number_plate: value.car.number_plate,
            make: value.car.make,
            model: value.car.model,
            year: value.car.year,
            dailyPrice: value.car.daily_price,
            mileage: value.car.mileage,
            status: value.car.status
        };

        if (cars.hasKey(newCar.number_plate)) {
            return error("Car with number plate " + value.car.number_plate + " already exists.");
        }else{cars.add(newCar);}
        
        return {number_plate: newCar.number_plate};
    }

    remote function UpdateCar(UpdateCarRequest value) returns Car|error {
            car updatedCar = {
            number_plate: value.updatedCar.number_plate,
            make: value.updatedCar.make,
            model: value.updatedCar.model,
            year: value.updatedCar.year,
            dailyPrice: value.updatedCar.daily_price,
            mileage: value.updatedCar.mileage,
            status: value.updatedCar.status
        };

        if (cars.hasKey(updatedCar.number_plate)) {
            return error("Car with number plate " + updatedCar.number_plate + " already exists.");
        }else{cars.put(updatedCar);}


        return {
            number_plate: updatedCar.number_plate,
            make: updatedCar.make,
            model: updatedCar.model,
            year: updatedCar.year,
            daily_price: updatedCar.dailyPrice,
            mileage: updatedCar.mileage,
            status: updatedCar.status
        };
    }


    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
         if (!cars.hasKey(value.number_plate)) {
            return error("Car with ID " + value.number_plate +" does not exist.");
        }else{car removedCar = cars.remove(value.number_plate);}

       Car[] remainingCars = [];
        foreach car c in cars {
            remainingCars.push({
                number_plate: c.number_plate,
                make: c.make,
                model: c.model,
                year: c.year,
                daily_price: c.dailyPrice,
                mileage: c.mileage,
                status: c.status
            });
        }
        return {cars: remainingCars};
    }

    remote function ListAllReservations(ListAllReservationsRequest value) returns ListAllReservationsResponse|error {
          Reservation[] booked = [];

    foreach var reservation in booked {
        if reservation.status == "confirmed" {
            booked.push(reservation);
        }
    }
    return {reservations: booked};
    }

    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
        if (!cars.hasKey(value.number_plate)) {
            return error("Car with number plate " + value.number_plate + " not found.");
        }
        car foundCar = cars.get(value.number_plate);
        return {car: {
            number_plate: foundCar.number_plate,
            make: foundCar.make,
            model: foundCar.model,
            year: foundCar.year,
            daily_price: foundCar.dailyPrice,
            mileage: foundCar.mileage,
            status: foundCar.status
        }};
    }

    remote function AddToCart(AddToCartRequest value) returns error? {
         boolean carExists = false;
        foreach car car in cars {
            if car.number_plate == value.cart_item.number_plate {
                carExists = true;
                if car.status != "available" {
                    return error("Car is not available");
                }
                break;
            }
        }
        
        if !carExists {
            return error("Car not found");
        }
        
        cart.push(value.cart_item);
        return ();
    }
    
remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
    if cart.length() == 0 {
        return error("Cart is empty");
    } else {
        reservation newReservation = {
            reservation_id: value.reservation.reservation_id,
            user_id: value.reservation.user_id,
            car_number_plate: value.reservation.car_number_plate,
            start_date: value.reservation.start_date,
            end_date: value.reservation.end_date,
            total_price: value.reservation.total_price,
            status: "confirmed"
        };
        reservations.push(newReservation);
        return {reservation_id: newReservation.reservation_id};
    }
}

remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
          int userCount = 0;
        
        error? result = clientStream.forEach(function(User user) {
            users.push({    
                id: user.id,
                name: user.name,
                userType: user.userType
            });
            userCount += 1;
        });
        
        if result is error {
            return result;
        }
        
        return {message: userCount.toString() + " users created"};
    }
    

remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?> {
        car[] carsAvailable = [];

    foreach var i in cars {
        if i.status == "available" {
            carsAvailable.push({
                number_plate: i.number_plate,
                make: i.make,
                model: i.model,
                year: i.year,
                dailyPrice: i.dailyPrice,   // local 'car' uses camelCase
                mileage: i.mileage,
                status: i.status
            });
        }

        stream<Car, error?> carStream = carsAvailable.toStream();
        return carStream;
    }
}
}