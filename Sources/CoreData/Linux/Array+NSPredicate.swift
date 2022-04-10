//
//  File.swift
//  
//
//  Created by David Trallero on 05/10/2020.
//

import Foundation

extension Array
{
    public func filter( using predicate: MIOPredicate? ) -> [NSManagedObject] {
        if predicate == nil { return self as! [NSManagedObject] }
        return filter { MIOPredicateEvaluate( object: $0 as! NSManagedObject, using: predicate! ) } as! [NSManagedObject]
//        return MIOPredicateEvaluateObjects(self as! [NSObject], using: predicate!) as! [NSManagedObject]
    }
    
}

extension Set
{
    public func filter( using predicate: MIOPredicate? ) -> [NSManagedObject] {
        if predicate == nil { return Array(self) as! [NSManagedObject] }
        return Array ( filter { MIOPredicateEvaluate( object: $0 as! NSManagedObject, using: predicate! ) } ) as! [NSManagedObject]
//        return MIOPredicateEvaluateObjects(self as! [NSObject], using: predicate!) as! [NSManagedObject]
    }
    
}
