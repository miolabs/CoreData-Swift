//
//  NSManagedObjectModel.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSManagedObjectModel : NSObject
{
    public convenience init?(contentsOf url: URL) {
        self.init()
                        
        let parser = MIOManagedObjectModelParser(url: url, model: self)

        // Make the xml deserialization synchronous
        let semaphore = DispatchSemaphore(value: 0)
        parser.parse { error in semaphore.signal() }
        _ = semaphore.wait(timeout: .distantFuture)
    }
        
    var _entitiesByName: [String : NSEntityDescription]?
    open var entitiesByName: [String : NSEntityDescription] {
        get {
            if _entitiesByName != nil { return _entitiesByName! }
            
            _entitiesByName = [:]
            for e in entities {
                _entitiesByName![e.name!] = e
            }
            
            return _entitiesByName!
        }
    }

    var _entities: [NSEntityDescription] = []
    open var entities: [NSEntityDescription] {
        get { return _entities }
        set {
            _entities = newValue
            _entitiesByName = nil
        }
    }

    var _configurations:[String] = []
    open var configurations: [String] { get { return _configurations } } // returns all available configuration names

    open func entities(forConfigurationName configuration: String?) -> [NSEntityDescription]? {
        return _entities
    }
    
    open func setEntities(_ entities: [NSEntityDescription], forConfigurationName configuration: String) {
        // NOTE: the getter of entityesByName IS NOT ATOMIC
        _entitiesByName = [:]

        for e in entities {
            _entities.append(e)
            _entitiesByName![e.name!] = e
//            print("NSManagedObjectModel:setEntities: Adding entity: \(e.name!)")
        }
    }
    
    /* Returns the collection of developer-defined version identifiers for the model.  For models created in Xcode, this value is set by the developer in the model inspector. Merged models return the combined  collection of identifiers. This value is meant to be used as a debugging hint to help developers determine the models that were combined to create a merged model. The framework does not give models a default identifier, nor does it depend this value at runtime.
    */
    var _versionIdentifiers: Set<AnyHashable> = Set()
    open var versionIdentifiers: Set<AnyHashable> {
        get { return _versionIdentifiers }
        set { _versionIdentifiers = newValue }
    }
    
    // To internal function to override
    open func registerDataModelRuntimeObjects() {}
    
}
