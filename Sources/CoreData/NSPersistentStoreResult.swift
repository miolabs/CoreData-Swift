//
//  NSPersistentStoreResult.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSPersistentStoreResult : NSObject
{
    
}

open class NSPersistentStoreAsynchronousResult : NSPersistentStoreResult
{
    var _managedObjectContext:NSManagedObjectContext
    open var managedObjectContext: NSManagedObjectContext { get { return _managedObjectContext } }

    var _operationError:Error?
    open var operationError: Error? { get { return _operationError } }

//    var _progress = Progress()
//    open var progress: Progress? { get { return _progress } }
    
    public override init() {
        _managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        super.init()
    }
    
    open func cancel(){
        
    }
}
