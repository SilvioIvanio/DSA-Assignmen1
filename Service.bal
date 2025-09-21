import ballerina/http;
import ballerina/time;

type Component record {
    string componentId;
    string name;
    string description;
};

type Schedule record {
    string scheduleId;
    string frequency; // "QUARTERLY", "YEARLY", etc.
    string nextDueDate; 
    string description;
};

type Task record {
    string taskId;
    string description;
    // "PENDING", "IN_PROGRESS", "COMPLETED"
    string status; 
};

type WorkOrder record {
    string workOrderId;
    string description;
    // "OPEN", "IN_PROGRESS", "CLOSED"
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
    string status; // "ACTIVE", "UNDER_REPAIR", "DISPOSED"
    string acquiredDate;
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

table<Asset> key(assetTag) assetsTable = table [];

service /asset_management on new http:Listener(8081) {
// Add component to asset
    resource function post assets/[string assetTag]/components(@http:Payload Component component) returns Component|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        asset.components[component.componentId] = component;
        assetsTable.put(asset);
        return component;
    }

    // Remove component from asset
    resource function delete assets/[string assetTag]/components/[string componentId]() returns Component|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        if (!asset.components.hasKey(componentId)) {
            return error("Component not found");
        }
        
        Component removedComponent = asset.components.remove(componentId);
        assetsTable.put(asset);
        return removedComponent;
    }

    // Add schedule to asset
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule schedule) returns Schedule|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        asset.schedules[schedule.scheduleId] = schedule;
        assetsTable.put(asset);
        return schedule;
    }

    // Remove schedule from asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Schedule|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        if (!asset.schedules.hasKey(scheduleId)) {
            return error("Schedule not found");
        }
        
        Schedule removedSchedule = asset.schedules.remove(scheduleId);
        assetsTable.put(asset);
        return removedSchedule;
    }

