import ballerina/time;
import ballerina/http;

// Defines the status of an asset.
public enum AssetStatus {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

// Defines a component of an asset.
public type Component record {
    readonly string componentId;
    string name;
    string description;
};

// Defines a maintenance schedule for an asset.
public type MaintenanceSchedule record {
    readonly string scheduleId;
    string maintenanceType;
    time:Date nextDueDate;
};

// Defines a small task under a work order.
public type Task record {
    readonly string taskId;
    string description;
    boolean isCompleted = false;
};

// Defines a work order for an asset.
public type WorkOrder record {
    readonly string workOrderId;
    string issue;
    Task[] tasks = [];
    string status = "OPEN"; // Consider using an enum for status as well
};

// Defines the main Asset record, including lists of its nested entities.
public type Asset record {
    readonly string assetTag; // The unique key for the asset
    string name;
    string faculty;
    string department;
    AssetStatus status;
    time:Date acquiredDate;
    Component[] components = [];
    MaintenanceSchedule[] schedules = [];
    WorkOrder[] workOrders = [];
};

// In-memory database (simulated using a Ballerina table)
table<Asset> key(assetTag) assetTable = table [];

// Service to manage assets
service /assetManagement on new http:Listener(8080) {
     // Adds a new asset to the system.
        resource function post addAsset(Asset newAsset) returns Asset|error {
            // code here
        }

    // Retrieves an asset by its tag
    resource function get [string assetTag]() returns Asset|http:NotFound|error {
        // code here
    }

    // Updates an existing asset
    resource function put [string assetTag](Asset updatedAsset) returns Asset|http:NotFound|error {
        // code here
    }

    // Deletes an asset by its tag
    resource function delete [string assetTag]() returns http:Ok|http:NotFound|error {
        // code here
    }
}