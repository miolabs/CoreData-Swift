//
//  NSManagedObjectID.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSManagedObjectID : NSObject
{
    var _entity:NSEntityDescription
    open var entity: NSEntityDescription { get { return _entity } } // entity for the object identified by an ID

    weak var _persistentStore:NSPersistentStore?
    weak open var persistentStore: NSPersistentStore? { get { return _persistentStore } } // persistent store that fetched the object identified by an ID

    // indicates whether or not this ID will be replaced later, such as after a save operation (temporary IDs are assigned to newly inserted objects and replaced with permanent IDs when an object is written to a persistent store); most IDs return NO
    var _isTemporaryID = true
    open var isTemporaryID: Bool { get { return _isTemporaryID } }

    var _storeIdentifier:String?
    open var _referenceObject:Any
    
    // URI which provides an archivable reference to the object which this ID refers
    open func uriRepresentation() -> URL {
        
        let host = isTemporaryID ? "": "/\(_storeIdentifier!)"
        
        let url = URL(string: "x-coredata://\(host)/\(_referenceObject)/\(_entity.name!)")
        return url!
    }

    init(WithEntity entity:NSEntityDescription, referenceObject:Any?){
        _entity = entity
        if referenceObject == nil {
            _referenceObject = UUID().uuidString.uppercased()
            _isTemporaryID = true
        }
        else {
            _referenceObject = referenceObject!
            _isTemporaryID = false
        }
    }
    
    //
    // Private methods
    //
    
    func setReferenceObject(referenceObject:Any) {
        _isTemporaryID = false
        _referenceObject = referenceObject
    }
    
}
