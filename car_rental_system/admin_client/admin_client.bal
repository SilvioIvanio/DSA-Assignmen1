import ballerina/io;

CarRentalServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddCarRequest add_carRequest = {car: {make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, plate: "ballerina", status: "AVAILABLE"}};
    AddCarResponse add_carResponse = check ep->add_car(add_carRequest);
    io:println(add_carResponse);

    UpdateCarRequest update_carRequest = {plate: "ballerina", updated_car: {make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, plate: "ballerina", status: "AVAILABLE"}};
    UpdateCarResponse update_carResponse = check ep->update_car(update_carRequest);
    io:println(update_carResponse);

    RemoveCarRequest remove_carRequest = {plate: "ballerina"};
    RemoveCarResponse remove_carResponse = check ep->remove_car(remove_carRequest);
    io:println(remove_carResponse);

    SearchCarRequest search_carRequest = {plate: "ballerina"};
    SearchCarResponse search_carResponse = check ep->search_car(search_carRequest);
    io:println(search_carResponse);

    AddToCartRequest add_to_cartRequest = {user_id: "ballerina", plate: "ballerina", start_date: "ballerina", end_date: "ballerina"};
    AddToCartResponse add_to_cartResponse = check ep->add_to_cart(add_to_cartRequest);
    io:println(add_to_cartResponse);

    PlaceReservationRequest place_reservationRequest = {user_id: "ballerina"};
    PlaceReservationResponse place_reservationResponse = check ep->place_reservation(place_reservationRequest);
    io:println(place_reservationResponse);

    Empty list_reservationsRequest = {};
    stream<Reservation, error?> list_reservationsResponse = check ep->list_reservations(list_reservationsRequest);
    check list_reservationsResponse.forEach(function(Reservation value) {
        io:println(value);
    });

    ListAvailableCarsRequest list_available_carsRequest = {filter: "ballerina"};
    stream<Car, error?> list_available_carsResponse = check ep->list_available_cars(list_available_carsRequest);
    check list_available_carsResponse.forEach(function(Car value) {
        io:println(value);
    });

    User create_usersRequest = {user_id: "ballerina", name: "ballerina", email: "ballerina", role: "CUSTOMER"};
    Create_usersStreamingClient create_usersStreamingClient = check ep->create_users();
    check create_usersStreamingClient->sendUser(create_usersRequest);
    check create_usersStreamingClient->complete();
    CreateUsersResponse? create_usersResponse = check create_usersStreamingClient->receiveCreateUsersResponse();
    io:println(create_usersResponse);
}
