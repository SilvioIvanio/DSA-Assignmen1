import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

    remote function add_car(AddCarRequest value) returns AddCarResponse|error {
        return error("Not implemented");
    }

    remote function update_car(UpdateCarRequest value) returns UpdateCarResponse|error {
        return error("Not implemented");
    }

    remote function remove_car(RemoveCarRequest value) returns RemoveCarResponse|error {
        return error("Not implemented");
    }

    remote function search_car(SearchCarRequest value) returns SearchCarResponse|error {
        return error("Not implemented");
    }

    remote function add_to_cart(AddToCartRequest value) returns AddToCartResponse|error {
        return error("Not implemented");    
    }

    remote function place_reservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        return error("Not implemented");
    }

    remote function create_users(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        return error("Not implemented");
    }

    remote function list_reservations(Empty value) returns stream<Reservation, error?>|error {
        return error("Not implemented");
    }

    remote function list_available_cars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        return error("Not implemented");
    }
}
