//
//  File.swift
//  
//
//  Created by Javier Segura Perez on 22/09/2020.
//

import Foundation

extension MIOCompoundPredicate
{
    public enum LogicalType : UInt
    {
        case not = 0
        case and = 1
        case or = 2
    }
}

open class MIOCompoundPredicate : MIOPredicate
{
    public init(type: MIOCompoundPredicate.LogicalType, subpredicates: [MIOPredicate]){
        _compoundPredicateType = type
        _subpredicates = subpredicates
    }

//    public init?(coder: NSCoder){
//
//    }

    init(type: MIOCompoundPredicate.LogicalType) {
        _compoundPredicateType = type
    }
    
    var _compoundPredicateType:MIOCompoundPredicate.LogicalType?
    open var compoundPredicateType: MIOCompoundPredicate.LogicalType { get { _compoundPredicateType! } }

    var _subpredicates:[MIOPredicate] = []
    open var subpredicates: [MIOPredicate] { get { _subpredicates } }

    func append(predicate: MIOPredicate) {
        _subpredicates.append(predicate)
    }
    
    /*** Convenience Methods ***/
    public /*not inherited*/ init(andPredicateWithSubpredicates subpredicates: [MIOPredicate]) {
        _compoundPredicateType = .and
        _subpredicates = subpredicates
    }

    public /*not inherited*/ init(orPredicateWithSubpredicates subpredicates: [MIOPredicate]) {
        _compoundPredicateType = .or
        _subpredicates = subpredicates
    }

    public /*not inherited*/ init(notPredicateWithSubpredicate predicate: MIOPredicate){
        _compoundPredicateType = .not
        _subpredicates = [predicate]
    }
    
    open override var description: String {
        get {

            var type = ""
            switch compoundPredicateType {
            case .and: type = " and "
            case .or:  type = " or "
            case .not: type = " not "
            }
            
            return subpredicates.map { $0.description }.joined(separator: type)
        }
    }

}

