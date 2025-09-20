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

