//
//  MIOSortDescriptor.swift
//  DLAPIServer
//
//  Created by Javier Segura Perez on 22/05/2019.
//

import Foundation

public typealias NSSortDescriptor = MIOSortDescriptor

open class MIOSortDescriptor : NSObject//, NSSecureCoding, NSCopying
{
    // keys may be key paths
    public init(key: String?, ascending: Bool){
        _key = key
        _ascending = ascending
    }

//    public init(key: String?, ascending: Bool, selector: Selector?)

//    public init?(coder: NSCoder)

    let _key: String?
    open var key: String? { get { return _key } }

    let _ascending: Bool
    open var ascending: Bool { get { return _ascending } }

//    open var selector: Selector? { get }

    
//    @available(macOS 10.9, *)
//    open func allowEvaluation() // Force a sort descriptor which was securely decoded to allow evaluation
//
//
//    @available(macOS 10.6, *)
//    public init(key: String?, ascending: Bool, comparator cmptr: @escaping Comparator)
//
//
//    @available(macOS 10.6, *)
//    open var comparator: Comparator { get }

    
//    open func compare(_ object1: Any, to object2: Any) -> ComparisonResult // primitive - override this method if you want to perform comparisons differently (not key based for example)

//    open var reversedSortDescriptor: Any { get } // primitive - override this method to return a sort descriptor instance with reversed sort order
}

/*
extension NSSortDescriptor {

    public convenience init<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool)

    public convenience init<Root, Value>(keyPath: KeyPath<Root, Value>, ascending: Bool, comparator cmptr: @escaping Comparator)

    public var keyPath: AnyKeyPath? { get }
}

extension NSSet {

    
    @available(macOS 10.6, *)
    open func sortedArray(using sortDescriptors: [NSSortDescriptor]) -> [Any] // returns a new array by sorting the objects of the receiver
}

 */

extension Array
{
    public func sortedArray(using sortDescriptors: [NSSortDescriptor]) -> [Element] {
        let results = sorted { a, b in
            
            for sd in sortDescriptors {
                let key = sd.key!
                
                let lv = a is NSManagedObject ? (a as! NSManagedObject).value(forKeyPath: key) : a
                let rv = b is NSManagedObject ? (b as! NSManagedObject).value(forKeyPath: key) : b

                if MIOPredicateEvaluateLess(lv, rv) { return sd.ascending }
                else if !MIOPredicateEvaluateLessEqual(lv, rv) { return !sd.ascending }
            }
                       
            return false
        }
     
        return results
    }
   
}


/*
extension NSArray {
    
    // returns a new array by sorting the objects of the receiver
    open func sortedArray(using sortDescriptors: [NSSortDescriptor]) -> [Any] { }


extension NSMutableArray {

    
    open func sort(using sortDescriptors: [NSSortDescriptor]) // sorts the array itself
}

extension NSOrderedSet {

    
    // returns a new array by sorting the objects of the receiver
    @available(macOS 10.7, *)
    open func sortedArray(using sortDescriptors: [NSSortDescriptor]) -> [Any]
}

extension NSMutableOrderedSet {

    
    // sorts the ordered set itself
    @available(macOS 10.7, *)
    open func sort(using sortDescriptors: [NSSortDescriptor])
}

*/
