//
//  NSFetchIndexDescription.swift
//  
//
//  Created by Javier Segura Perez on 02/09/2020.
//

import Foundation

open class NSFetchIndexDescription : NSObject, NSCopying
{
    public func copy(with zone: NSZone? = nil) -> Any {
        let obj = NSFetchIndexDescription(name:name, elements: elements)
        return obj
    }
    
    public init(name: String, elements: [NSFetchIndexElementDescription]?)
    {
        self.name = name
        self.elements = elements ?? []
    }
     
    open var name: String

    /* Will throw if the new value is invalid (ie includes both rtree and non-rtree elements). */
    open var elements: [NSFetchIndexElementDescription]

    //unowned(unsafe) open var entity: NSEntityDescription? { get }
       
    /* If the index should be a partial index, specifies the predicate selecting rows for indexing */
    @NSCopying open var partialIndexPredicate: NSPredicate?
}
