import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
        return error("Not implemented");
    }

    remote function UpdateCar(UpdateCarRequest value) returns Car|error {
        return error("Not implemented");
    }

    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
        return error("Not implemented");
    }

    remote function ListAllReservations(ListAllReservationsRequest value) returns ListAllReservationsResponse|error {
        return error("Not implemented");
    }

    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
        return error("Not implemented");
    }

    remote function AddToCart(AddToCartRequest value) returns error? {
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        return error("Not implemented");
    }

    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        return error("Not implemented");
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        return error("Not implemented");
    }
}
