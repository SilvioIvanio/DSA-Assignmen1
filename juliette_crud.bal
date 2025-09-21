// Create (Add) asset
resource function post assets(Asset newAsset) returns Asset|error {
    if (assetsTable.hasKey(newAsset.assetTag)) {
        return error("Asset already exists with this tag");
    }
    assetsTable.put(newAsset);
    return newAsset;
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
