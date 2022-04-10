//
//  NSFetchIndexElementDescription.swift
//  
//
//  Created by Javier Segura Perez on 02/09/2020.
//

import Foundation

public enum NSFetchIndexElementType : UInt
{
    case binary = 0
    case rTree = 1
}

open class NSFetchIndexElementDescription : NSObject
{
    public init(property: NSPropertyDescription, collationType: NSFetchIndexElementType)
    {
        _property = property
        self.collationType = collationType
    }
    
    /* This may be an NSExpressionDescription that expresses a function */
    var _property:NSPropertyDescription!
    open var property: NSPropertyDescription? { get { _property } }

    open var propertyName: String? { get { return property?.name } }

    /* Default NSIndexTypeBinary */
    open var collationType: NSFetchIndexElementType = .binary

    /* Default YES. Control whether this is an ascending or descending index for indexes which support direction. */
    
    open var isAscending: Bool = true
   
    unowned(unsafe) open var indexDescription: NSFetchIndexDescription? { get { nil } }

}
