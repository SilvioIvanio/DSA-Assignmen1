import ballerina/io;
import ballerina/http;

type Component record {
    string componentId;
    string name;
    string description;
};

type Schedule record {
    string scheduleId;
    string frequency;
    string nextDueDate;
    string description;
};

type Task record {
    string taskId;
    string description;
    string status;
};

type WorkOrder record {
    string workOrderId;
    string description;
    string status;
    string dateOpened;
    string? dateClosed;
    Task[] tasks;
};

type Asset record {
    readonly string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

http:Client client_asset = check new ("http://localhost:8081/asset_management");

public function main() returns error? {
    io:println("NUST Facilities Directorate Asset Management System");
    io:println("\n");
    io:println("Please select an action by entering the corresponding number:");
    io:println("1. Register a new asset");
    io:println("2. Show all assets");
    io:println("3. Modify an existing asset");
    io:println("4. Find asset by tag");
    io:println("5. Remove an asset");
    io:println("6. List assets by faculty");
    io:println("7. Check overdue maintenance");
    io:println("8. Component management");
    io:println("9. Schedule management");
    io:println("10. Work order management");
    io:println("11. Exit");
    
    while true {
        string cli = io:readln("Enter your choice (1-11)> ");
        if cli == "11" {
            io:println("Exiting system. Goodbye!");
            break;
        }
        _ = check CLI(cli);
    }
}

function CLI(string cli) returns error? {
    match cli {
        "1" => {
            string assetTag = io:readln("Enter Asset Tag: ");
            string name = io:readln("Enter Asset Name: ");
            string faculty = io:readln("Faculty: ");
            string department = io:readln("Department: ");
            string status = io:readln("Current Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
            string acquiredDate = io:readln("Acquired Date (YYYY-MM-DD): ");
            
            Asset asset = {
                assetTag: assetTag,
                name: name,
                faculty: faculty,
                department: department,
                status: status,
                acquiredDate: acquiredDate,
                components: {},
                schedules: {},
                workOrders: {}
            };
            
            Asset assetResp = check client_asset->/assets.post(asset);
            io:println("✅ Asset registered successfully:");
            io:println(assetResp.toJsonString());
            io:println("------------------------------------------------\n");
        }
        
        "2" => {
            Asset[] assets = check client_asset->/assets;
            io:println("📋 Asset Directory:");
            io:println("================================================");
            foreach Asset asset in assets {
            io:println(asset.toJsonString());
            io:println("------------------------------------------------\n");
    }
}

        
        "3" => {
            string assetTag = io:readln("Enter Asset Tag to modify: ");
            string name = io:readln("New Asset Name: ");
            string faculty = io:readln("New Faculty: ");
            string department = io:readln("New Department: ");
            string status = io:readln("Updated Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
            string acquiredDate = io:readln("New Acquired Date (YYYY-MM-DD): ");
            
            Asset updatedAsset = {
                assetTag: assetTag,
                name: name,
                faculty: faculty,
                department: department,
                status: status,
                acquiredDate: acquiredDate,
                components: {},
                schedules: {},
                workOrders: {}
            };
            
            Asset assetResp = check client_asset->/assets/[assetTag].put(updatedAsset);
            io:println("✅ Asset information updated:");
            io:println(assetResp.toJsonString());
        }
        
        "4" => {
            string assetTag = io:readln("Enter Asset Tag: ");
            Asset asset = check client_asset->/assets/[assetTag];
            io:println("📌 Asset Details:");
            io:println(asset.toJsonString());
        }
        
        "5" => {
            string assetTag = io:readln("Enter Asset Tag to delete: ");
            Asset removedAsset = check client_asset->/assets/[assetTag].delete();
            io:println("🗑️ Asset removed: " + removedAsset.toJsonString());
        }
        
        "6" => {
            string faculty = io:readln("Enter Faculty: ");
            Asset[] assets = check client_asset->/assets/faculty/[faculty];
            io:println("Assets under faculty: " + faculty);
            foreach Asset asset in assets {
                io:println(asset.toJsonString());
            }
        }
        
        "7" => {
            Asset[] overdueAssets = check client_asset->/assets/overdue;
            io:println("🔧 Assets with overdue maintenance:");
            if (overdueAssets.length() > 0) {
                foreach Asset asset in overdueAssets {
                    io:println(asset.toJsonString());
                }
            } else {
                io:println("✅ All assets are up-to-date with maintenance.");
            }
        }
        
        "8" => {
            io:println("⚙️ Component Management");
            io:println("1. Add a component");
            io:println("2. Delete a component");
            string choice = io:readln("Select option (1-2): ");
            
            if choice == "1" {
                string assetTag = io:readln("Asset Tag: ");
                string componentId = io:readln("Component ID: ");
                string name = io:readln("Component Name: ");
                string description = io:readln("Component Description: ");
                
                Component component = {
                    componentId: componentId,
                    name: name,
                    description: description
                };
                
                Component addedComponent = check client_asset->/assets/[assetTag]/components.post(component);
                io:println("✅ Component added:");
                io:println(addedComponent.toJsonString());
            } else if choice == "2" {
                string assetTag = io:readln("Asset Tag: ");
                string componentId = io:readln("Component ID to delete: ");
                
                Component removedComponent = check client_asset->/assets/[assetTag]/components/[componentId].delete();
                io:println("🗑️ Component deleted:");
                io:println(removedComponent.toJsonString());
            }
        }
        
        "9" => {
            io:println("📅 Schedule Management");
            io:println("1. Add a schedule");
            io:println("2. Delete a schedule");
            string choice = io:readln("Select option (1-2): ");
            
            if choice == "1" {
                string assetTag = io:readln("Asset Tag: ");
                string scheduleId = io:readln("Schedule ID: ");
                string frequency = io:readln("Frequency (QUARTERLY/YEARLY): ");
                string nextDueDate = io:readln("Next Due Date (YYYY-MM-DD): ");
                string description = io:readln("Description: ");
                
                Schedule schedule = {
                    scheduleId: scheduleId,
                    frequency: frequency,
                    nextDueDate: nextDueDate,
                    description: description
                };
                
                Schedule addedSchedule = check client_asset->/assets/[assetTag]/schedules.post(schedule);
                io:println("✅Schedule created:");
                io:println(addedSchedule.toJsonString());
            } else if choice == "2" {
                string assetTag = io:readln("Asset Tag: ");
                string scheduleId = io:readln("Schedule ID to delete: ");
                
                Schedule removedSchedule = check client_asset->/assets/[assetTag]/schedules/[scheduleId].delete();
                io:println("🗑️ Schedule deleted:");
                io:println(removedSchedule.toJsonString());
            }
        }
        
        "10" => {
            io:println("📂 Work Order Management");
            io:println("1. Create work order");
            io:println("2. Update work order status");
            io:println("3. Add task to work order");
            string choice = io:readln("Select option (1-3): ");
            
            if choice == "1" {
                string assetTag = io:readln("Asset Tag: ");
                string workOrderId = io:readln("Work Order ID: ");
                string description = io:readln("Work Order Description: ");
                string status = io:readln("Status (OPEN/IN_PROGRESS/CLOSED): ");
                string dateOpened = io:readln("Date Opened (YYYY-MM-DD): ");
                
                WorkOrder workOrder = {
                    workOrderId: workOrderId,
                    description: description,
                    status: status,
                    dateOpened: dateOpened,
                    dateClosed: (),
                    tasks: []
                };
                
                WorkOrder addedWorkOrder = check client_asset->/assets/[assetTag]/workorders.post(workOrder);
                io:println("✅ Work Order created:");
                io:println(addedWorkOrder.toJsonString());
            } else if choice == "2" {
                string assetTag = io:readln("Asset Tag: ");
                string workOrderId = io:readln("Work Order ID: ");
                string description = io:readln("Work Order Description: ");
                string status = io:readln("Updated Status (OPEN/IN_PROGRESS/CLOSED): ");
                string dateOpened = io:readln("Date Opened (YYYY-MM-DD): ");
                string dateClosed = io:readln("Date Closed (YYYY-MM-DD or leave empty): ");
                
                WorkOrder workOrder = {
                    workOrderId: workOrderId,
                    description: description,
                    status: status,
                    dateOpened: dateOpened,
                    dateClosed: dateClosed == "" ? () : dateClosed,
                    tasks: []
                };
                
                WorkOrder updatedWorkOrder = check client_asset->/assets/[assetTag]/workorders/[workOrderId].put(workOrder);
                io:println("✅ Work Order updated:");
                io:println(updatedWorkOrder.toJsonString());
            } else if choice == "3" {
                string assetTag = io:readln("Asset Tag: ");
                string workOrderId = io:readln("Work Order ID: ");
                string taskId = io:readln("Task ID: ");
                string description = io:readln("Task Description: ");
                string status = io:readln("Task Status (PENDING/IN_PROGRESS/COMPLETED): ");
                
                Task task = {
                    taskId: taskId,
                    description: description,
                    status: status
                };
                
                Task addedTask = check client_asset->/assets/[assetTag]/workorders/[workOrderId]/tasks.post(task);
                io:println("✅ Task added:");
                io:println(addedTask.toJsonString());
            }
        }
        
        _ => {
            io:println("⚠️ Invalid selection. Please pick a number from 1 to 11.");
        }
    }
}
