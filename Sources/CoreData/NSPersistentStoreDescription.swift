//
//  NSPersistentStoreDescription.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSPersistentStoreDescription : NSObject
{
    open var type: String

    open var configuration: String?

    open var url: URL?

    open var options: [String : NSObject] { get { return _options } }
    
    var _options:[String: NSObject] = [:]
    open func setOption(_ option: NSObject?, forKey key: String) {
        
        if option == nil {
            _options.removeValue(forKey: key)
        }
        
        _options[key] = option!
    }

    
    // Store options
    open var isReadOnly = false

    //open var timeout: TimeInterval

//    open var sqlitePragmas: [String : NSObject] { get }
//
//    open func setValue(_ value: NSObject?, forPragmaNamed name: String) {
//
//    }
    
    // addPersistentStore-time behaviours
//    open var shouldAddStoreAsynchronously: Bool
//
//    open var shouldMigrateStoreAutomatically: Bool
//
//    open var shouldInferMappingModelAutomatically: Bool

    
    public override init() {
        self.type = "None"
    }
    
    // Returns a store description instance with default values for the store located at `URL` that can be used immediately with `addPersistentStoreWithDescription:completionHandler:`.
    public init(url: URL){
        self.url = url
        self.type = "None"
        super.init()
    }
}
