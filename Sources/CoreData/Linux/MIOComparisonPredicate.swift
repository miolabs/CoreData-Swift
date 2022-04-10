//
//  MIOComparisonPredicate.swift
//  
//
//  Created by Javier Segura Perez on 05/06/2020.
//

import Foundation

// Comparison predicates are predicates which do some form of comparison between the results of two expressions and return a BOOL. They take an operator, a left expression, and a right expression, and return the result of invoking the operator with the results of evaluating the expressions.

open class MIOComparisonPredicate : MIOPredicate
{
    public init(leftExpression lhs: MIOExpression, rightExpression rhs: MIOExpression, modifier: Modifier, type: Operator, options: Options) {
        _leftExpression = lhs
        _rightExpression = rhs
        _modifier = modifier
        _operator = type
        _options = options
        super.init()
    }
        
    var _operator:Operator
    open var predicateOperatorType: Operator { return _operator }

    var _modifier:Modifier
    open var comparisonPredicateModifier: Modifier { return _modifier }
    
    var _leftExpression:MIOExpression
    open var leftExpression: MIOExpression {  return _leftExpression }

    var _rightExpression:MIOExpression
    open var rightExpression: MIOExpression { return _rightExpression }
    
    var _options:Options
    open var options: Options { return _options }

    public struct Options : OptionSet {
        public let rawValue : UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        public static let caseInsensitive = Options(rawValue : 0x1)
        public static let diacriticInsensitive = Options(rawValue : 0x2)
        public static let normalized = Options(rawValue : 0x4) /* Indicate that the strings to be compared have been preprocessed; this supersedes other options and is intended as a performance optimization option */
    }
    
    // Describes how the operator is modified: can be direct, ALL, or ANY
    public enum Modifier : UInt {
        case direct // Do a direct comparison
        case all // ALL toMany.x = y
        case any // ANY toMany.x = y
    }
    
    // Type basic set of operators defined. Most are obvious
    public enum Operator : UInt {
        case lessThan // compare: returns NSOrderedAscending
        case lessThanOrEqualTo // compare: returns NSOrderedAscending || NSOrderedSame
        case greaterThan // compare: returns NSOrderedDescending
        case greaterThanOrEqualTo // compare: returns NSOrderedDescending || NSOrderedSame
        case equalTo // isEqual: returns true
        case notEqualTo // isEqual: returns false
        case matches
        case like
        case beginsWith
        case endsWith
        case `in` // rhs contains lhs returns true
        case contains // lhs contains rhs returns true
        case between
    }
    
    open override var description: String {
        get {
            var str = ""
            str += leftExpression.description + " "
            switch _operator {
            case .lessThan: str += "lessThan"
            case .lessThanOrEqualTo:  str += "lessThanOrEqualTo"
            case .greaterThan: str += "greaterThan"
            case .greaterThanOrEqualTo: str += "greaterThanOrEqualTo"
            case .equalTo: str += "equalTo"
            case .notEqualTo: str += "notEqualTo"
            case .matches: str += "matches"
            case .like: str += "like"
            case .beginsWith: str += "beginsWith"
            case .endsWith: str += "endsWith"
            case .in: str += "in"
            case .contains: str += "contains"
            case .between: str += "between"
            }
            str += " " + rightExpression.description
            return str
        }
    }

}
