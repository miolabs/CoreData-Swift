//
//  NSPersistentStore.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSPersistentStore : NSObject
{
    /* Get metadata from the persistent store at url. Must be overriden by subclasses.
       Subclasses should validate that the URL is the type of URL they are expecting, and
       should verify that the file contents are appropriate for the store type before
       attempting to read from it. This method should never raise an exception.
     */
//    open class func metadataForPersistentStore(with url: URL) throws -> [String : Any] {
//
//    }

    /* Set the medatada of the store at url to metadata. Must be overriden by subclasses. */
    open class func setMetadata(_ metadata: [String : Any]?, forPersistentStoreAt url: URL) throws {
        
    }

    /* Returns the NSMigrationManager class optimized for this store class.  Subclasses of NSPersistentStore can override this to provide a custom migration manager subclass (eg to take advantage of store-specific functionality to improve migration performance).
     */
    //open class func migrationManagerClass() -> AnyClass

    
    /* the designated initializer for object stores. */
    public required init(persistentStoreCoordinator root: NSPersistentStoreCoordinator?, configurationName name: String?, at url: URL, options: [AnyHashable : Any]? = nil) {
        _persistentStoreCoordinator = root
        _configurationName = name ?? "Default"
        _options = options
        super.init()
        
        self.url = url
        try? loadMetadata()
        identifier = metadata[NSStoreUUIDKey] as? String
    }
    
    /*  Store metadata must be accessible before -load: is called, but there is no way to return an error if the store is invalid
    */
    open func loadMetadata() throws {
    }
    
    /* the bridge between the control & access layers. */
    weak var _persistentStoreCoordinator:NSPersistentStoreCoordinator?
    weak open var persistentStoreCoordinator: NSPersistentStoreCoordinator? { get { return _persistentStoreCoordinator } }
    
    var _configurationName = "Default"
    open var configurationName: String { get { return _configurationName } } // Which configuration does this store contain

    var _options:[AnyHashable : Any]?
    open var options: [AnyHashable : Any]? { get { return _options } } // the options the store was initialized with
    
    open var url: URL?
    
    open var identifier: String!
        
    open var type: String { get { return "NSPersistentStore" } } // stores always know their type
    
    open var isReadOnly = false // Do we know a priori the store is read only?

    
    open var metadata: [String : Any]! // includes store type and UUID

    
    // Gives the store a chance to do any post-init work that's necessary
    open func didAdd(to coordinator: NSPersistentStoreCoordinator) {}

    
    // Gives the store a chance to do any non-dealloc teardown (for example, closing a network connection)
    // before removal.
    open func willRemove(from coordinator: NSPersistentStoreCoordinator?) {}
    
    // Private methods

    var objectsByEntityName:[ Int: [ Int: [ String:Any ] ] ] = [:]
    
    func save (insertedObjects: Set<NSManagedObject>, updatedObjects: Set<NSManagedObject>, deletedObjects: Set <NSManagedObject>, context:NSManagedObjectContext) throws {}

}

struct ObjectsSet
{
    var objectsByID:[Int:ObjectValues]
}

struct ObjectValues
{
    var values: [String: Any]
}
