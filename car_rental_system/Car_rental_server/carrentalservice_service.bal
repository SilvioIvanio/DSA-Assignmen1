import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
    }

    remote function UpdateCar(UpdateCarRequest value) returns Car|error {
    }

    remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
    }

    remote function ListAllReservations(ListAllReservationsRequest value) returns ListAllReservationsResponse|error {
    }

    remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
    }

    remote function AddToCart(AddToCartRequest value) returns error? {
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
    }

    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
    }
}
