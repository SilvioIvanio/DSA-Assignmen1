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

    // new asset
    resource function post assets(Asset newAsset) returns Asset|error {
        if (assetsTable.hasKey(newAsset.assetTag)) {
            return error("Asset already exists with this tag");
        }
        assetsTable.put(newAsset);
        return newAsset;
    }

    // Get assets
    resource function get assets() returns Asset[] {
        Asset[] allAssets = [];
        foreach Asset asset in assetsTable {
            allAssets.push(asset);
        }
        return allAssets;
    }

    // Get specific asset by tag
    resource function get assets/[string assetTag]() returns Asset|error {
        Asset? asset = assetsTable[assetTag];
        if (asset is ()) {
            return error("Asset not found with this tag");
        }
        return asset;
    }

    // Update existing asset
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|error {
        Asset? existingAssetOpt = assetsTable[assetTag];
        
        if (existingAssetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset existingAsset = existingAssetOpt;
        
        // Update fields
        existingAsset.name = updatedAsset.name;
        existingAsset.faculty = updatedAsset.faculty;
        existingAsset.department = updatedAsset.department;
        existingAsset.status = updatedAsset.status;
        existingAsset.acquiredDate = updatedAsset.acquiredDate;
        
        assetsTable.put(existingAsset);
        return existingAsset;
    }

    // Delete asset
    resource function delete assets/[string assetTag]() returns Asset|error {
        Asset? asset = assetsTable[assetTag];
        if (asset is ()) {
            return error("Asset not found with this tag");
        }
        Asset removedAsset = assetsTable.remove(assetTag);
        return removedAsset;
    }

    // Get  by faculty
    resource function get assets/faculty/[string faculty]() returns Asset[]|error {
        Asset[] facultyAssets = [];
        
        foreach Asset asset in assetsTable {
            if (asset.faculty == faculty) {
                facultyAssets.push(asset);
            }
        }
        
        if (facultyAssets.length() == 0) {
            return error("No assets found for this faculty");
        }
        return facultyAssets;
    }

    // Get overdue assets (maintenance schedules past due)
    resource function get assets/overdue() returns Asset[]|error {
        Asset[] overdueAssets = [];
        time:Utc currentTime = time:utcNow();
        foreach Asset asset in assetsTable {
            foreach Schedule schedule in asset.schedules {
                time:Civil|error dueDate = time:civilFromString(schedule.nextDueDate);
                if (dueDate is time:Civil) {
                    time:Utc|error dueDateUtc = time:utcFromCivil(dueDate);
                    if (dueDateUtc is time:Utc) {
                        decimal diffSeconds = time:utcDiffSeconds(currentTime, dueDateUtc);
                        if (diffSeconds > 0.0d) {
                            overdueAssets.push(asset);
                            break; 
                        }
                    }
                }
            }
        }
        
        return overdueAssets;
    }

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

    // Add work order to asset
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns WorkOrder|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        asset.workOrders[workOrder.workOrderId] = workOrder;
        assetsTable.put(asset);
        return workOrder;
    }

    // Update work order status
    resource function put assets/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns WorkOrder|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        if (!asset.workOrders.hasKey(workOrderId)) {
            return error("Work order not found");
        }
        
        asset.workOrders[workOrderId] = updatedWorkOrder;
        assetsTable.put(asset);
        return updatedWorkOrder;
    }

    // Add task to work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) returns Task|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        WorkOrder? workOrderOpt = asset.workOrders[workOrderId];
        if (workOrderOpt is ()) {
            return error("Work order not found");
        }
        
        WorkOrder workOrder = workOrderOpt;
        workOrder.tasks.push(task);
        asset.workOrders[workOrderId] = workOrder;
        assetsTable.put(asset);
        return task;
    }

    // Remove task from work order
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns Task|error {
        Asset? assetOpt = assetsTable[assetTag];
        if (assetOpt is ()) {
            return error("Asset not found with this tag");
        }
        
        Asset asset = assetOpt;
        WorkOrder? workOrderOpt = asset.workOrders[workOrderId];
        if (workOrderOpt is ()) {
            return error("Work order not found");
        }
        
        WorkOrder workOrder = workOrderOpt;
        Task? removedTask = ();
        
        foreach int i in 0...workOrder.tasks.length()-1 {
            if (workOrder.tasks[i].taskId == taskId) {
                removedTask = workOrder.tasks.remove(i);
                break;
            }
        }
        
        if (removedTask is ()) {
            return error("Task not found");
        }
        
        asset.workOrders[workOrderId] = workOrder;
        assetsTable.put(asset);
        return <Task>removedTask;
    }
}