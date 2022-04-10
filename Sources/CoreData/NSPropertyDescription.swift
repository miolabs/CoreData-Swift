//
//  NSPropertyDescription.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSPropertyDescription : NSObject
{
    open weak var _entity:NSEntityDescription!
    unowned(unsafe) open var entity: NSEntityDescription { get { return _entity! } }
    
    var _name:String?
    open var name: String { get { return _name! } set { _name = newValue } }
    
    // The optional flag specifies whether a property's value can be nil or not (before an object can be persisted).
    open var isOptional: Bool = true
    
    // The transient flag specifies whether a property's value is persisted or ignored when an object is persisted - transient properties are still managed for undo/redo, validation, etc.
    open var isTransient: Bool = false
    
    open var userInfo: [AnyHashable : Any]?
    
    public override init() {}
    
    init(name:String, optional:Bool, transient:Bool) {
        _name = name
        isOptional = optional
        isTransient = transient
        super.init()
    }
}
