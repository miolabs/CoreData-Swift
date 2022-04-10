//
//  NSPersistentStoreCoordinator.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation
import MIOCore

// Persistent store types supported by Core Data:
public let NSSQLiteStoreType = "NSSQLiteStoreType"
public let NSBinaryStoreType = "NSBinaryStoreType"
public let NSInMemoryStoreType = "NSInMemoryStoreType"

// Persistent store metadata dictionary keys:

// key in the metadata dictionary to identify the store type
public let NSStoreTypeKey = "NSStoreTypeKey"

// key in the metadata dictionary to identify the store UUID - the store UUID is useful to identify stores through URI representations, but it is NOT guaranteed to be unique (while the UUID generated for new stores is unique, users can freely copy files and thus the UUID stored inside, so developers that track/reference stores explicitly do need to be aware of duplicate UUIDs and potentially override the UUID when a new store is added to the list of known stores in their application)
public let NSStoreUUIDKey = "NSStoreUUIDKey"


open class NSPersistentStoreCoordinator : NSObject
{
    open var managedObjectModel:NSManagedObjectModel
        
    init(managedObjectModel: NSManagedObjectModel) {
        self.managedObjectModel = managedObjectModel
    }
    
    var _persistentStores:[NSPersistentStore] = []
    open var persistentStores: [NSPersistentStore] { get { return _persistentStores } }

    open var name: String?

    open func persistentStore(for URL: URL) -> NSPersistentStore? {
        return nil
    }

//    open func url(for store: NSPersistentStore) -> URL {
//
//    }

    open func setURL(_ url: URL, for store: NSPersistentStore) -> Bool {
        return true
    }

    open func addPersistentStore(ofType storeType: String, configurationName configuration: String?, at storeURL: URL?, options: [AnyHashable : Any]? = nil) throws -> NSPersistentStore {
        
        NSLog("NSPersistentStoreCoordinator:addPersistentStore: Loading store type: \(storeType)")
                
        let storeClass = NSPersistentStoreCoordinator.registeredStoreTypes[storeType] as! NSPersistentStore.Type        
        let store = storeClass.init(persistentStoreCoordinator: self, configurationName: configuration, at: storeURL ?? URL(string: "localhost")! , options: nil)
        _persistentStores.append(store)
        
        return store
    }
    
    open func addPersistentStore(with storeDescription: NSPersistentStoreDescription, completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        
    }
    
    open func remove(_ store: NSPersistentStore) throws {
        
    }

    open func setMetadata(_ metadata: [String : Any]?, for store: NSPersistentStore) {
        
    }

//    open func metadata(for store: NSPersistentStore) -> [String : Any] {
//
//    }

    open func managedObjectID(forURIRepresentation url: URL) -> NSManagedObjectID? {
        return nil
    }
 
//    open func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext) throws -> Any {
//
//    }
    
    static let _store_queue = DispatchQueue(label: "com.miocoredata.store_queue")
    static var _registeredStoreTypes:[String:Any] = [NSSQLiteStoreType: NSSQLiteStore.self, NSBinaryStoreType: NSBinaryStore.self, NSInMemoryStoreType: NSInMemoryStore.self]
    open class var registeredStoreTypes: [String : Any] { get {
        var types:[String:Any] = [:]
        _store_queue.sync {
            for (k, t) in _registeredStoreTypes {
                types[k] = t
            }
        }
        return types
    } }
    
    open class func registerStoreClass(_ storeClass: AnyClass?, forStoreType storeType: String) {
        _store_queue.sync {
            _registeredStoreTypes[storeType] = storeClass
        }
    }
    
    open class func metadataForPersistentStore(ofType storeType: String, at url: URL, options: [AnyHashable : Any]? = nil) throws -> [String : Any] {
        return [:]
    }
    
    open class func setMetadata(_ metadata: [String : Any]?, forPersistentStoreOfType storeType: String, at url: URL, options: [AnyHashable : Any]? = nil) throws {
        
    }

}
