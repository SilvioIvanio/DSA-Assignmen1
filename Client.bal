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