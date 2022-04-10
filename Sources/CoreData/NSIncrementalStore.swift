//
//  NSIncrementalStore.swift
//  
//
//  Created by Javier Segura Perez on 15/05/2020.
//

import Foundation


open class NSIncrementalStore : NSPersistentStore
{
    // CoreData expects loadMetadata: to validate that the URL used to create the store is usable
    // (location exists, is writable (if applicable), schema is compatible, etc) and return an
    // error if there is an issue.
    // Any subclass of NSIncrementalStore which is file-based must be able to handle being initialized
    // with a URL pointing to a zero-length file. This serves as an indicator that a new store is to be
    // constructed at the specified location and allows applications using the store to securly create
    // reservation files in known locations.
    open override func loadMetadata() throws {
        
    }

    
    // API methods that must be overriden by a subclass:
    
    // Return a value as appropriate for the request, or nil if the request cannot be completed.
    // If the request is a fetch request whose result type is set to one of NSManagedObjectResultType,
    // NSManagedObjectIDResultType, NSDictionaryResultType, return an array containing all objects
    // in the store matching the request.
    // If the request is a fetch request whose result type is set to NSCountResultType, return an
    // array containing an NSNumber of all objects in the store matching the request.
    // If the request is a save request, the result should be an empty array. Note that
    // save requests may have nil inserted/updated/deleted/locked collections; this should be
    // treated as a request to save the store metadata.
    // Note that subclasses of NSIncrementalStore should implement this method conservatively,
    // and expect that unknown request types may at some point be passed to the
    // method. The correct behavior in these cases would be to return nil and an error.
    open func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext?) throws -> Any {
        return [NSManagedObject]()
    }

    
    // Returns an NSIncrementalStoreNode encapsulating the persistent external values for the object for an objectID.
    // It should include all attributes values and may include to-one relationship values as NSManagedObjectIDs.
    // Should return nil and set the error if the object cannot be found.
    open func newValuesForObject(with objectID: NSManagedObjectID, with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        return NSIncrementalStoreNode(objectID: objectID, withValues: [String:Any](), version: 1)
    }

    
    // Returns the relationship for the given relationship on the object with ID objectID. If the relationship
    // is a to-one it should return an NSManagedObjectID corresponding to the destination or NSNull if the relationship value is nil.
    // If the relationship is a to-many, should return an NSSet or NSArray containing the NSManagedObjectIDs of the related objects.
    // Should return nil and set the error if the source object cannot be found.
    open func newValue(forRelationship relationship: NSRelationshipDescription, forObjectWith objectID: NSManagedObjectID, with context: NSManagedObjectContext?) throws -> Any {
        return ""
    }

    
    // API methods that may be overriden:
    open class func identifierForNewStore(at storeURL: URL) -> Any {
        return ""
    }

    
    // Called before executeRequest with a save request, to assign permanent IDs to newly inserted objects;
    // must return the objectIDs in the same order as the objects appear in array.
    open func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        return array.map{ NSManagedObjectID( WithEntity: $0.entity, referenceObject: nil ) }
        // return [NSManagedObjectID]()
    }

    
    // Inform the store that the objects with ids in objectIDs are in use in a client NSManagedObjectContext
    open func managedObjectContextDidRegisterObjects(with objectIDs: [NSManagedObjectID]) {
        
    }

    
    // Inform the store that the objects with ids in objectIDs are no longer in use in a client NSManagedObjectContext
    open func managedObjectContextDidUnregisterObjects(with objectIDs: [NSManagedObjectID]) {
        
    }

    
    // API utility methods that should not be overriden (implemented by NSIncrementalStore):
    
    // Returns a new objectID with retain count 1 that uses data as the key.
    open func newObjectID(for entity: NSEntityDescription, referenceObject data: Any) -> NSManagedObjectID {
        let objID = NSManagedObjectID(WithEntity: entity, referenceObject: data)
        objID._persistentStore = self
        objID._storeIdentifier = identifier
        // --- print("New REFID: \(entity.name!)://\(String(describing: data))")

        return objID
    }

    // Returns the reference data used to construct the objectID. Will raise an NSInvalidArgumentException if the objectID was not created
    // by this store.
    open func referenceObject(for objectID: NSManagedObjectID) -> Any {
        return objectID._referenceObject
    }
    
    
    override func save (insertedObjects: Set<NSManagedObject>, updatedObjects: Set<NSManagedObject>, deletedObjects: Set <NSManagedObject>, context:NSManagedObjectContext) throws {
        
        let saveRequest = NSSaveChangesRequest(inserted: insertedObjects, updated: updatedObjects, deleted: deletedObjects, locked: nil)
                                
        try _obtainPermanentIDs(for: Array(insertedObjects), context: context)
        _ = try execute(saveRequest, with: context)
    }
    
    func _obtainPermanentIDs(for objects: [NSManagedObject], context:NSManagedObjectContext) throws {
        
//        let temporaryIDs = objects.map { $0.objectID }
                
        let objIDs = try obtainPermanentIDs(for: objects)
        
        for i in 0..<objects.count {
//            let oldID = temporaryIDs[i]
            let newID = objIDs[i]
            let obj = objects[i]
            
            context._unregisterObject(obj, notifyStore: false)
            
//            objectsByID.removeValue(forKey: oldID.uriRepresentation().absoluteString)
//            objectsByID[newID.uriRepresentation().absoluteString] = obj
            
            obj.objectID._referenceObject = newID._referenceObject
            obj.objectID._storeIdentifier = newID._storeIdentifier
            obj.objectID._isTemporaryID   = newID._isTemporaryID
            obj.objectID._persistentStore = newID._persistentStore
            
            context._registerObject(obj, notifyStore: false)
        }
        
//        delete this.objectsByID[object.objectID.URIRepresentation.absoluteString];

//        object.objectID._setReferenceObject(objID._getReferenceObject());

//        this.objectsByID[object.objectID.URIRepresentation.absoluteString] = object;
    }

}
