service /asset_management on new http:Listener(8081) {

    // --- ASSET CRUD ---
    resource function post assets(Asset newAsset) returns Asset|error {
        if (assetsTable.hasKey(newAsset.assetTag)) {
            return error("Asset already exists with this tag");
        }
        assetsTable.put(newAsset);
        return newAsset;
    }

    resource function get assets() returns Asset[] {
        Asset[] allAssets = [];
        foreach Asset asset in assetsTable {
            allAssets.push(asset);
        }
        return allAssets;
    }

    resource function get assets/[string assetTag]() returns Asset|error {
        Asset? asset = assetsTable[assetTag];
        if (asset is ()) {
            return error("Asset not found with this tag");
        }
        return asset;
    }

    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|error {
        Asset? existingAssetOpt = assetsTable[assetTag];
        if (existingAssetOpt is ()) {
            return error("Asset not found with this tag");
        }
        Asset existingAsset = existingAssetOpt;
        existingAsset.name = updatedAsset.name;
        existingAsset.faculty = updatedAsset.faculty;
        existingAsset.department = updatedAsset.department;
        existingAsset.status = updatedAsset.status;
        existingAsset.acquiredDate = updatedAsset.acquiredDate;
        assetsTable.put(existingAsset);
        return existingAsset;
    }

    resource function delete assets/[string assetTag]() returns Asset|error {
        Asset? asset = assetsTable[assetTag];
        if (asset is ()) {
            return error("Asset not found with this tag");
        }
        Asset removedAsset = assetsTable.remove(assetTag);
        return removedAsset;
    }

    // --- COMPONENT CRUD ---
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

    // --- SCHEDULE CRUD ---
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

    // --- WORK ORDER CRUD ---
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

    // --- TASK CRUD ---
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
