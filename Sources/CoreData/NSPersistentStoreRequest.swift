//
//  NSPersistentStoreRequest.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

public enum NSPersistentStoreRequestType : UInt
{
    case none
    case fetchRequestType = 1
    case saveRequestType = 2
    case batchDeleteRequestType = 5
    case batchUpdateRequestType = 6
    case batchInsertRequestType = 7
}

open class NSPersistentStoreRequest : NSObject
{
    // Stores this request should be sent to.
    open var affectedStores: [NSPersistentStore]?
      
    // The type of the request.
    open var requestType: NSPersistentStoreRequestType { get { return .none } }
}
