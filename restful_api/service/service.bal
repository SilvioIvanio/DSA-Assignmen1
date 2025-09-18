import ballerina/http;
//import ballerina/time;

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
    string nextDueDate;
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
    string acquiredDate;
    Component[] components = [];
    MaintenanceSchedule[] schedules = [];
    WorkOrder[] workOrders = [];
};

// In-memory database (simulated using a Ballerina table)
table<Asset> key(assetTag) assetTable = table [
    {
        assetTag: "AST001",
        name: "3D Printer",
        faculty: "Engineering",
        department: "Mechanical",
        status: ACTIVE,
        acquiredDate: "2022-05-01T00:00:00Z",
        components: [
            {componentId: "CMP001", name: "Nozzle", description: "Printing nozzle"},
            {componentId: "CMP002", name: "Bed Plate", description: "Heated print bed"}
        ],
        schedules: [
            {scheduleId: "SCH001", maintenanceType: "Calibration", nextDueDate: "2025-10-01T00:00:00Z"}
        ],
        workOrders: []
    },
    {
        assetTag: "AST002",
        name: "Laptop Dell XPS",
        faculty: "ICT",
        department: "Computer Science",
        status: UNDER_REPAIR,
        acquiredDate: "2021-09-15T00:00:00Z",
        components: [
            {componentId: "CMP003", name: "Battery", description: "Lithium-ion battery"},
            {componentId: "CMP004", name: "SSD", description: "512GB SSD"}
        ],
        schedules: [
            {scheduleId: "SCH002", maintenanceType: "Software Update", nextDueDate: "2025-09-30T00:00:00Z"}
        ],
        workOrders: [
            {
                workOrderId: "WO001",
                issue: "Battery not charging",
                tasks: [
                    {taskId: "TSK001", description: "Diagnose battery issue", isCompleted: true},
                    {taskId: "TSK002", description: "Replace battery", isCompleted: false}
                ],
                status: "OPEN"
            }
        ]
    },
    {
        assetTag: "AST003",
        name: "Microscope",
        faculty: "Science",
        department: "Biology",
        status: ACTIVE,
        acquiredDate: "2020-01-20T00:00:00Z",
        components: [
            {componentId: "CMP005", name: "Lens", description: "40x zoom lens"}
        ],
        schedules: [
            {scheduleId: "SCH003", maintenanceType: "Cleaning", nextDueDate: "2025-12-01T00:00:00Z"}
        ],
        workOrders: []
    },
    {
        assetTag: "AST004",
        name: "Air Conditioner",
        faculty: "Administration",
        department: "Facilities",
        status: UNDER_REPAIR,
        acquiredDate: "2019-07-10T00:00:00Z",
        components: [
            {componentId: "CMP006", name: "Compressor", description: "Cooling compressor"},
            {componentId: "CMP007", name: "Filter", description: "Air filter"}
        ],
        schedules: [
            {scheduleId: "SCH004", maintenanceType: "Filter Replacement", nextDueDate: "2025-09-25T00:00:00Z"}
        ],
        workOrders: [
            {
                workOrderId: "WO002",
                issue: "Not cooling properly",
                tasks: [
                    {taskId: "TSK003", description: "Inspect compressor", isCompleted: false}
                ],
                status: "OPEN"
            }
        ]
    },
    {
        assetTag: "AST005",
        name: "Projector",
        faculty: "Education",
        department: "Lectures",
        status: ACTIVE,
        acquiredDate: "2023-03-18T00:00:00Z",
        components: [
            {componentId: "CMP008", name: "Lamp", description: "Projection lamp"}
        ],
        schedules: [
            {scheduleId: "SCH005", maintenanceType: "Lamp Replacement", nextDueDate: "2026-03-18T00:00:00Z"}
        ],
        workOrders: []
    },
    {
        assetTag: "AST006",
        name: "Server Rack",
        faculty: "ICT",
        department: "Networking",
        status: DISPOSED,
        acquiredDate: "2015-11-11T00:00:00Z",
        components: [
            {componentId: "CMP009", name: "Switch", description: "48-port switch"},
            {componentId: "CMP010", name: "Power Unit", description: "Power supply"}
        ],
        schedules: [],
        workOrders: []
    }
];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(8080) {
    // Adds a new asset to the system.
    resource function post assets(@http:Payload Asset newAsset) returns error? {
        // Check if the asset with the same tag already exists
        if (assetTable.hasKey(newAsset.assetTag)) {
            return error("Asset with tag '" + newAsset.assetTag + "' already exists.");
        }
        // Insert the new asset into the table
        assetTable.add(newAsset);
    }
 
    // Retrieves an asset by its tag
    resource function get assets/[string assetTag]() returns Asset|error {
        Asset? asset = assetTable.get(assetTag);
        if asset is Asset {
            return asset;
        } else {
            return error("Asset with tag '" + assetTag + "' not found.");
        }
    }

    // Retrieves all assets
    resource function get assets() returns Asset[] {
        Asset[] assets = [];
        foreach var asset in assetTable {
            assets.push(asset);
        }
        return assets;
    }

    // Updates an existing asset
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns error? {
        if (!assetTable.hasKey(assetTag)) {
            return error("Asset with tag '" + assetTag + "' not found.");
        }
        
        assetTable.put(updatedAsset);
    }

    // Deletes an asset by its tag
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound|error {
        if (!assetTable.hasKey(assetTag)) {
            return http:NOT_FOUND;
        }

        _ = assetTable.remove(assetTag);
        return http:OK;
    }
}
