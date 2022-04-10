//
//  MIOAttributeDescription.swift
//  
//
//  Created by Javier Segura Perez on 21/05/2019.
//

import Foundation

public enum NSAttributeType : UInt
{
    case undefinedAttributeType = 0
    case integer16AttributeType = 100
    case integer32AttributeType = 200
    case integer64AttributeType = 300
    case decimalAttributeType = 400
    case doubleAttributeType = 500
    case floatAttributeType = 600
    case stringAttributeType = 700
    case booleanAttributeType = 800
    case dateAttributeType = 900
    case binaryDataAttributeType = 1000
    case UUIDAttributeType = 1100
    case URIAttributeType = 1200
    case transformableAttributeType = 1800 // If your attribute is of NSTransformableAttributeType, the attributeValueClassName must be set or attribute value class must implement NSCopying.
    case objectIDAttributeType = 2000
}

open class NSAttributeDescription: NSPropertyDescription
{
    // NSUndefinedAttributeType is valid for transient properties - Core Data will still track the property as an id value and register undo/redo actions, etc. NSUndefinedAttributeType is illegal for non-transient properties.
    open var attributeType: NSAttributeType = .undefinedAttributeType

    open var attributeValueClassName: String?
    
    open var defaultValue: Any? // value is retained and not copied
        
    public override init() {
        super.init()
    }
    
    public init(name:String, type:NSAttributeType, defaultValue:Any?, optional:Bool, transient:Bool){        
        self.attributeType = type
        self.defaultValue = defaultValue
        super.init(name: name, optional: optional, transient: transient)
    }
}
