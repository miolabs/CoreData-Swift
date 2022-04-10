//
//  File.swift
//  
//
//  Created by Javier Segura Perez on 15/3/21.
//

import Foundation

class NSInMemoryStore : NSPersistentStore
{
    override func loadMetadata() throws {
        self.metadata = [NSStoreUUIDKey: UUID().uuidString.uppercased(), NSStoreTypeKey: NSInMemoryStoreType]
    }
                        
    override func save (insertedObjects: Set<NSManagedObject>, updatedObjects: Set<NSManagedObject>, deletedObjects: Set <NSManagedObject>, context:NSManagedObjectContext) throws {
        
        for o in insertedObjects {
            var objects = objectsByEntityName[ o.entity.name!.hashValue ]
            if objects == nil {
                objects = [ Int: [ String:Any ] ]()
                objectsByEntityName[ o.entity.name!.hashValue ] = objects
            }
            let id = o.objectID.uriRepresentation().absoluteURL.hashValue
            objects![id] = o.changedValues()
        }
        
    }
}
