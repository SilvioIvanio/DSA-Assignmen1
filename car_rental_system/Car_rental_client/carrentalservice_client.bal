import ballerina/io;

CarRentalServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddCarRequest addCarRequest = {car: {number_plate: "ballerina", make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, status: "ballerina"}};
    AddCarResponse addCarResponse = check ep->AddCar(addCarRequest);
    io:println(addCarResponse);

    UpdateCarRequest updateCarRequest = {number_plate: "ballerina", updatedCar: {number_plate: "ballerina", make: "ballerina", model: "ballerina", year: 1, daily_price: 1, mileage: 1, status: "ballerina"}};
    Car updateCarResponse = check ep->UpdateCar(updateCarRequest);
    io:println(updateCarResponse);

    RemoveCarRequest removeCarRequest = {number_plate: "ballerina"};
    RemoveCarResponse removeCarResponse = check ep->RemoveCar(removeCarRequest);
    io:println(removeCarResponse);

    ListAllReservationsRequest listAllReservationsRequest = {adminId: "ballerina"};
    ListAllReservationsResponse listAllReservationsResponse = check ep->ListAllReservations(listAllReservationsRequest);
    io:println(listAllReservationsResponse);

    SearchCarRequest searchCarRequest = {number_plate: "ballerina"};
    SearchCarResponse searchCarResponse = check ep->SearchCar(searchCarRequest);
    io:println(searchCarResponse);

    AddToCartRequest addToCartRequest = {cart_item: {number_plate: "ballerina", start_date: "ballerina", end_date: "ballerina"}};
    check ep->AddToCart(addToCartRequest);

    PlaceReservationRequest placeReservationRequest = {customerId: "ballerina"};
    PlaceReservationResponse placeReservationResponse = check ep->PlaceReservation(placeReservationRequest);
    io:println(placeReservationResponse);

    ListAvailableCarsRequest listAvailableCarsRequest = {filter_text: "ballerina"};
    stream<Car, error?> listAvailableCarsResponse = check ep->ListAvailableCars(listAvailableCarsRequest);
    check listAvailableCarsResponse.forEach(function(Car value) {
        io:println(value);
    });

    User createUsersRequest = {userId: "ballerina", name: "ballerina", userType: "ballerina"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->CreateUsers();
    check createUsersStreamingClient->sendUser(createUsersRequest);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println(createUsersResponse);
}
