//
//  NSSaveChangesRequest.swift
//  
//
//  Created by Javier Segura Perez on 18/05/2020.
//

import Foundation

open class NSSaveChangesRequest : NSPersistentStoreRequest
{
    // Default initializer.
    public init(inserted insertedObjects: Set<NSManagedObject>?, updated updatedObjects: Set<NSManagedObject>?, deleted deletedObjects: Set<NSManagedObject>?, locked lockedObjects: Set<NSManagedObject>?){
        
        _insertedObjects = insertedObjects
        _updateObjects = updatedObjects
        _deletedObjects = deletedObjects
        _lockedObjects = lockedObjects
    }
    
    var _insertedObjects:Set<NSManagedObject>?
    // Objects that were inserted into the calling context.
    open var insertedObjects: Set<NSManagedObject>? { get { return _insertedObjects } }

    var _updateObjects:Set<NSManagedObject>?
    // Objects that were modified in the calling context.
    open var updatedObjects: Set<NSManagedObject>? { get { return _updateObjects } }

    var _deletedObjects:Set<NSManagedObject>?
    // Objects that were deleted from the calling context.
    open var deletedObjects: Set<NSManagedObject>? { get { return _deletedObjects } }

    var _lockedObjects:Set<NSManagedObject>?
    // Objects that were flagged for optimistic locking on the calling context via detectConflictsForObject:.
    open var lockedObjects: Set<NSManagedObject>? { get { return _lockedObjects } }
}
