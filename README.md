# DSA - Assignmen 1

This project contains two separate applications: a RESTful Asset Management System and a gRPC-based Car Rental System. Both applications are built using the Ballerina programming language.

## 1. RESTful API - Asset Management System

This project is a RESTful API for managing assets for the Facilities Directorate at NUST. It allows for the creation, tracking, and maintenance of assets such as laboratory equipment, servers, and vehicles.

### Features

- **Asset Management:** Create, update, retrieve, and delete assets.
- **Component Management:** Add and remove components associated with an asset.
- **Maintenance Schedules:** Manage servicing schedules for assets.
- **Work Orders:** Create and manage work orders for asset repairs.
- **Task Management:** Add and remove tasks within a work order.
- **Filtering:** View all assets, filter assets by faculty, and check for overdue maintenance items.

### How to Run

1.  **Run the Service:**
    - Navigate to the `Restful API/restful_api/service` directory.
    - Run the command: `bal run`

2.  **Run the Client:**
    - Navigate to the `Restful API/restful_api/client` directory.
    - Run the command: `bal run`
    - The client provides a command-line interface (CLI) to interact with the service.

### API Endpoints

The service runs on `http://localhost:8081/asset_management`. Here are the available endpoints:

- `POST /assets`: Create a new asset.
- `GET /assets`: Retrieve all assets.
- `GET /assets/{assetTag}`: Retrieve a specific asset by its tag.
- `PUT /assets/{assetTag}`: Update an existing asset.
- `DELETE /assets/{assetTag}`: Delete an asset.
- `GET /assets/faculty/{faculty}`: Get assets by faculty.
- `GET /assets/overdue`: Get assets with overdue maintenance schedules.
- `POST /assets/{assetTag}/components`: Add a component to an asset.
- `DELETE /assets/{assetTag}/components/{componentId}`: Remove a component from an asset.
- `POST /assets/{assetTag}/schedules`: Add a schedule to an asset.
- `DELETE /assets/{assetTag}/schedules/{scheduleId}`: Remove a schedule from an asset.
- `POST /assets/{assetTag}/workorders`: Add a work order to an asset.
- `PUT /assets/{assetTag}/workorders/{workOrderId}`: Update a work order.
- `POST /assets/{assetTag}/workorders/{workOrderId}/tasks`: Add a task to a work order.
- `DELETE /assets/{assetTag}/workorders/{workOrderId}/tasks/{taskId}`: Remove a task from a work order.

## 2. gRPC - Car Rental System

This project is a gRPC-based system for managing a car rental service. It supports two user roles: Admin and Customer.

### Features

#### Admin

- **Car Management:** Add, update, and remove cars from the system.
- **User Management:** Create new users (both Admins and Customers).
- **View Reservations:** List all reservations made by customers.

#### Customer

- **Browse Cars:** List all available cars for rent.
- **Search:** Search for a specific car by its license plate.
- **Shopping Cart:** Add cars to a rental cart with specified dates.
- **Reservations:** Place a reservation from the items in the cart.

### How to Run

1.  **Run the Server:**
    - Navigate to the `Car Rental System/car_rental_system/server` directory.
    - Run the command: `bal run`

2.  **Run the Admin Client:**
    - Navigate to the `Car Rental System/car_rental_system/admin_client` directory.
    - Run the command: `bal run`
    - The admin client provides a CLI for administrative tasks.

3.  **Run the Customer Client:**
    - Navigate to the `Car Rental System/car_rental_system/customer_client` directory.
    - Run the command: `bal run`
    - The customer client provides a CLI for customers to rent cars.

### gRPC Service Definition

The gRPC service is defined in the `Car_rental.proto` file. The service `CarRentalService` runs on `localhost:9090` and exposes the following RPCs:

#### Admin Operations

- `add_car`: Add a new car.
- `create_users`: Create new users in a batch.
- `update_car`: Update a car's details.
- `remove_car`: Remove a car from the system.
- `list_reservations`: List all reservations.

#### Customer Operations

- `list_available_cars`: List all available cars.
- `search_car`: Search for a car by its plate.
- `add_to_cart`: Add a car to the shopping cart.
- `place_reservation`: Place a reservation.
