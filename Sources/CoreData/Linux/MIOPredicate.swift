//
//  File.swift
//  
//
//  Created by Javier Segura Perez on 01/06/2020.
//

import Foundation
import MIOCore

#if canImport(CoreFoundation)
import CoreFoundation
#endif


public typealias NSExpression = MIOExpression
public typealias NSComparisonPredicate = MIOComparisonPredicate
public typealias NSPredicate = MIOPredicate
public typealias NSCompoundPredicate = MIOCompoundPredicate

enum MIOPredicateError : Error
{
    case invalidFunction
}

open class MIOPredicate: NSObject, NSCopying
{
    public func copy(with zone: NSZone? = nil) -> Any {
        let obj = MIOPredicate()
        return obj
    }
}

/*
 extension NSPredicate {
 
 public convenience init(format predicateFormat: String, _ args: CVarArg...) {
 //let array = getVaList(args)
 self.init(format:predicateFormat, argumentArray:nil)
 //object_setClass(self, MIOComparisonPredicate.self)
 
 }
 
 }
 */

public func MIOPredicateWithFormat(format: String, _ args: CVarArg...) -> MIOPredicate
{
    let lexer = MIOPredicateTokenize(format)
    let predicate = try! MIOPredicateParseTokens(lexer: lexer, args)
    
    return predicate
}

public enum MIOPredicateTokenType: Int
{
    case identifier
    
    case uuidValue
    case stringValue
    case numberValue
    case booleanValue
    case nullValue
    case propertyValue
    
    case minorOrEqualComparator
    case minorComparator
    case majorOrEqualComparator
    case majorComparator
    case equalComparator
    case distinctComparator
    case containsComparator
    case inComparator
    case notIntComparator
    
    case bitwiseAND
    case bitwiseOR
    case bitwiseXOR
    
    case plusOperation
    case minusOperation
    case multiplyOperation
    case divisionOperation
    
    case arraySymbol
    case openParenthesisSymbol
    case closeParenthesisSymbol
    case whitespace
    
    case and
    case or
    case not
    
    case any
    case all
    
    case classValue
}

let g_tokens = [
    ( MIOPredicateTokenType.uuidValue.rawValue,    try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options:.caseInsensitive) ),
    ( MIOPredicateTokenType.stringValue.rawValue,  try! NSRegularExpression(pattern: "^\"([^\"]*)\"|^'([^']*)'") ),
    ( MIOPredicateTokenType.numberValue.rawValue,  try! NSRegularExpression(pattern:"^-?\\d+(?:\\.\\d+)?(?:e[+\\-]?\\d+)?", options:.caseInsensitive) ),
    ( MIOPredicateTokenType.booleanValue.rawValue, try! NSRegularExpression(pattern:"^(true|false)", options:.caseInsensitive) ),
    ( MIOPredicateTokenType.nullValue.rawValue,    try! NSRegularExpression(pattern:"^(null|nil)", options:.caseInsensitive) ),
    ( MIOPredicateTokenType.arraySymbol.rawValue,  try! NSRegularExpression(pattern: "^\\[([^\\]]*)\\]") ),
    ( MIOPredicateTokenType.openParenthesisSymbol.rawValue,  try!  NSRegularExpression(pattern:"^\\(") ),
    ( MIOPredicateTokenType.closeParenthesisSymbol.rawValue, try! NSRegularExpression(pattern:"^\\)") ),
    ( MIOPredicateTokenType.minorOrEqualComparator.rawValue, try! NSRegularExpression(pattern:"^<=") ),
    ( MIOPredicateTokenType.minorComparator.rawValue,        try! NSRegularExpression(pattern:"^<") ),
    ( MIOPredicateTokenType.majorOrEqualComparator.rawValue, try! NSRegularExpression(pattern:"^>=") ),
    ( MIOPredicateTokenType.majorComparator.rawValue,        try! NSRegularExpression(pattern:"^>") ),
    ( MIOPredicateTokenType.equalComparator.rawValue,        try! NSRegularExpression(pattern:"^==?") ),
    ( MIOPredicateTokenType.distinctComparator.rawValue,     try! NSRegularExpression(pattern:"^!=") ),
    ( MIOPredicateTokenType.containsComparator.rawValue,     try! NSRegularExpression(pattern:"^contains ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.inComparator.rawValue,           try! NSRegularExpression(pattern:"^in ", options:.caseInsensitive) ),
    ( MIOPredicateTokenType.bitwiseAND.rawValue,             try! NSRegularExpression(pattern:"^& ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.bitwiseOR.rawValue,              try! NSRegularExpression(pattern:"^\\| ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.bitwiseXOR.rawValue,             try! NSRegularExpression(pattern:"^\\^", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.and.rawValue,                    try! NSRegularExpression(pattern:"^(and|&&) ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.or.rawValue,                     try! NSRegularExpression(pattern:"^(or|\\|\\|) ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.not.rawValue,                    try! NSRegularExpression(pattern:"^not ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.any.rawValue,                    try! NSRegularExpression(pattern:"^any ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.all.rawValue,                    try! NSRegularExpression(pattern:"^all ", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.whitespace.rawValue,             try! NSRegularExpression(pattern:"^\\s+", options: .caseInsensitive) ),
    
    ( MIOPredicateTokenType.classValue.rawValue,             try! NSRegularExpression(pattern:"^%@", options: .caseInsensitive) ),
    ( MIOPredicateTokenType.identifier.rawValue,             try! NSRegularExpression(pattern:"^[a-zA-Z_][a-zA-Z0-9-_\\.]*") ),

]

func MIOPredicateTokenize(_ predicateFormat: String) -> MIOCoreLexer
{
    let lexer = MIOCoreLexer()
    
    // Values
    for t in g_tokens {
        lexer.addTokenType(t.0, regex: t.1)
    }
    lexer.ignoreTokenType(MIOPredicateTokenType.whitespace.rawValue)
        
//    lexer.addTokenType(MIOPredicateTokenType.stringValue.rawValue, regex: try! NSRegularExpression(pattern: "^\"([^\"]*)\"|^'([^']*)'"))
//    lexer.addTokenType(MIOPredicateTokenType.numberValue.rawValue, regex: try! NSRegularExpression(pattern:"^-?\\d+(?:\\.\\d+)?(?:e[+\\-]?\\d+)?", options:.caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.booleanValue.rawValue, regex: try! NSRegularExpression(pattern:"^(true|false)", options:.caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.nullValue.rawValue, regex: try! NSRegularExpression(pattern:"^(null|nil)", options:.caseInsensitive))
//
//    // Symbols
//    lexer.addTokenType(MIOPredicateTokenType.arraySymbol.rawValue, regex: try! NSRegularExpression(pattern: "^\\[([^\\]]*)\\]"))
//    lexer.addTokenType(MIOPredicateTokenType.openParenthesisSymbol.rawValue, regex: try! NSRegularExpression(pattern:"^\\("))
//    lexer.addTokenType(MIOPredicateTokenType.closeParenthesisSymbol.rawValue, regex: try! NSRegularExpression(pattern:"^\\)"))
//
//    // Comparators
//    lexer.addTokenType(MIOPredicateTokenType.minorOrEqualComparator.rawValue, regex: try! NSRegularExpression(pattern:"^<="))
//    lexer.addTokenType(MIOPredicateTokenType.minorComparator.rawValue, regex: try! NSRegularExpression(pattern:"^<"))
//    lexer.addTokenType(MIOPredicateTokenType.majorOrEqualComparator.rawValue, regex: try! NSRegularExpression(pattern:"^>="))
//    lexer.addTokenType(MIOPredicateTokenType.majorComparator.rawValue, regex: try! NSRegularExpression(pattern:"^>"))
//    lexer.addTokenType(MIOPredicateTokenType.equalComparator.rawValue, regex: try! NSRegularExpression(pattern:"^==?"))
//    lexer.addTokenType(MIOPredicateTokenType.distinctComparator.rawValue, regex: try! NSRegularExpression(pattern:"^!="))
//    lexer.addTokenType(MIOPredicateTokenType.containsComparator.rawValue, regex: try! NSRegularExpression(pattern:"^contains ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.inComparator.rawValue, regex: try! NSRegularExpression(pattern:"^in ", options:.caseInsensitive))
//
//    // Bitwise operators
//    lexer.addTokenType(MIOPredicateTokenType.bitwiseAND.rawValue, regex: try! NSRegularExpression(pattern:"^& ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.bitwiseOR.rawValue, regex: try! NSRegularExpression(pattern:"^\\| ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.bitwiseXOR.rawValue, regex: try! NSRegularExpression(pattern:"^\\^", options: .caseInsensitive))
//
//    // Operations
//    //this.lexer.addTokenType(MIOPredicateTokenType.MinusOperation, /^- /i);
//    // Join operators
//    lexer.addTokenType(MIOPredicateTokenType.and.rawValue, regex: try! NSRegularExpression(pattern:"^(and|&&) ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.or.rawValue, regex: try! NSRegularExpression(pattern:"^(or|\\|\\|) ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.not.rawValue, regex: try! NSRegularExpression(pattern:"^not ", options: .caseInsensitive))
////    // Relationship operators
//    lexer.addTokenType(MIOPredicateTokenType.any.rawValue, regex: try! NSRegularExpression(pattern:"^any ", options: .caseInsensitive))
//    lexer.addTokenType(MIOPredicateTokenType.all.rawValue, regex: try! NSRegularExpression(pattern:"^all ", options: .caseInsensitive))
//    // Extra
//    lexer.addTokenType(MIOPredicateTokenType.whitespace.rawValue, regex: try! NSRegularExpression(pattern:"^\\s+", options: .caseInsensitive))
//    lexer.ignoreTokenType(MIOPredicateTokenType.whitespace.rawValue)
//
//    // Placeholder
//    lexer.addTokenType(MIOPredicateTokenType.classValue.rawValue, regex: try! NSRegularExpression(pattern:"^%@", options: .caseInsensitive))
//
//    // Identifiers - Has to be the last one
//    lexer.addTokenType(MIOPredicateTokenType.identifier.rawValue, regex: try! NSRegularExpression(pattern:"^[a-zA-Z_][a-zA-Z0-9-_\\.]*"))
    
    lexer.tokenize(withString: predicateFormat)
    return lexer
}

func MIOPredicateParseTokens(lexer: MIOCoreLexer, _ args: [Any]) throws -> MIOPredicate
{
    var token = lexer.nextToken()
    let exit = false
    
    var lastPredicate:MIOPredicate?
    var lastCompoundPredicate:MIOCompoundPredicate?
    var rootPredicate:MIOPredicate?
    var compoundPredicateStack:[MIOCompoundPredicate] = []
    
    while (token != nil && exit == false) {
        
        switch (token!.type) {
        
        case MIOPredicateTokenType.identifier.rawValue:
            
            var op:MIOComparisonPredicate.Operator? = nil
            var functionType:MIOExpression.FunctionType? = nil
            MIOPredicateParseOperatorOrFunction(lexer, op: &op, functionType: &functionType)
            let leftExpression: NSExpression
            
            if op != nil {
                leftExpression = MIOExpression(forKeyPath: token!.value)
            }
            else {
                switch functionType {
                case .bitwiseAnd, .bitwiseOr, .bitwiseXor:
                    let arg1 = MIOExpression(forKeyPath: token!.value)
                    let arg2 = MIOPredicateParseExpresion(lexer, args)
                    leftExpression = MIOExpression(forFunction: functionType!.rawValue, arguments: [arg1, arg2])
                    MIOPredicateParseOperatorOrFunction(lexer, op: &op, functionType: &functionType)
                    
                default:
                    throw MIOPredicateError.invalidFunction
                }
            }
            
            let rightExpression = MIOPredicateParseExpresion(lexer, args)
            let predicate = MIOComparisonPredicate(leftExpression: leftExpression, rightExpression: rightExpression, modifier: .direct, type: op!, options: [])
            
            if lastCompoundPredicate?.compoundPredicateType == .not {
                lastCompoundPredicate!.append(predicate: predicate)
                lastPredicate = nil
            }
            else {
                lastPredicate = predicate
            }
            
            //predicates.append(predicate)
                    
        case MIOPredicateTokenType.and.rawValue:
                                                   
            if lastCompoundPredicate?._compoundPredicateType == .and && lastPredicate != nil {
                lastCompoundPredicate!.append(predicate: lastPredicate!)
                lastPredicate = nil
                break
            }

            let predicate = MIOCompoundPredicate(type: .and)
            
            if lastPredicate != nil {
                predicate.append(predicate: lastPredicate!)
                lastPredicate = nil
            }
            
            if lastCompoundPredicate != nil && lastCompoundPredicate!.compoundPredicateType == .not {
                predicate.append(predicate: lastCompoundPredicate!)
            }
            else if lastCompoundPredicate != nil {
                lastCompoundPredicate!.append(predicate: predicate)
            }
            
            lastCompoundPredicate = predicate
            if rootPredicate == nil { rootPredicate = predicate }
            
        case MIOPredicateTokenType.or.rawValue:
            if lastCompoundPredicate?._compoundPredicateType == .or && lastPredicate != nil {
                lastCompoundPredicate!.append(predicate: lastPredicate!)
                lastPredicate = nil
                break
            }
                        
            let predicate = MIOCompoundPredicate(type: .or)
            
            if lastPredicate != nil {
                predicate.append(predicate: lastPredicate!)
                lastPredicate = nil
            }
            
            if lastCompoundPredicate != nil && lastCompoundPredicate!.compoundPredicateType == .not {
                predicate.append(predicate: lastCompoundPredicate!)
            }
            else if lastCompoundPredicate != nil {
                lastCompoundPredicate!.append(predicate: predicate)
            }
            
            lastCompoundPredicate = predicate
            if rootPredicate == nil { rootPredicate = predicate }

        case MIOPredicateTokenType.not.rawValue:
            lastCompoundPredicate = MIOCompoundPredicate(type: .not)
                    

        case MIOPredicateTokenType.openParenthesisSymbol.rawValue:
            if lastCompoundPredicate != nil { compoundPredicateStack.append(lastCompoundPredicate!) }
            lastCompoundPredicate = nil
            
        case MIOPredicateTokenType.closeParenthesisSymbol.rawValue:
            if lastCompoundPredicate != nil && lastPredicate != nil {
                lastCompoundPredicate!.append(predicate: lastPredicate!)
                lastPredicate = nil
            }
            
            let predicate = compoundPredicateStack.last
            if predicate != nil && lastCompoundPredicate != nil { predicate!.append(predicate: lastCompoundPredicate!) }
            else if predicate != nil && lastPredicate != nil { predicate!.append(predicate: lastPredicate!) }
            lastCompoundPredicate = predicate
            
        /*
         case MIOPredicateTokenType.ANY:
         this.lexer.nextToken();
         let anyPI = this.nextPredicateItem();
         anyPI.relationshipOperation = MIOPredicateRelationshipOperatorType.ANY;
         predicates.push(anyPI);
         break;
         
         case MIOPredicateTokenType.ALL:
         this.lexer.nextToken();
         let allPI = this.nextPredicateItem();
         anyPI.relationshipOperation = MIOPredicateRelationshipOperatorType.ALL;
         predicates.push(anyPI);
         break;
         
         case MIOPredicateTokenType.OpenParenthesisSymbol:
         let pg = new MIOPredicateGroup();
         pg.predicates = this.parsePredicates();
         predicates.push(pg);
         break;
         
         case MIOPredicateTokenType.CloseParenthesisSymbol:
         exit = true;
         break;*/
        
        default:
            //throw new Error(`MIOPredicate: Error. Unexpected token. (${token.value})`);
            break
        }
        
        if exit != true {
            token = lexer.nextToken()
        }
    }
    
    if compoundPredicateStack.count == 0 && lastCompoundPredicate == nil && lastPredicate != nil {
        return lastPredicate!
    }
    
    if lastCompoundPredicate != nil && lastPredicate != nil {
        lastCompoundPredicate!.append(predicate: lastPredicate!)
    }
             
    if rootPredicate == nil && lastCompoundPredicate != nil {
        return lastCompoundPredicate!
    }
    
    if rootPredicate == nil && compoundPredicateStack.count > 0 {
        return compoundPredicateStack.first!
    }
    
    return rootPredicate!
    
}

func MIOPredicateParseExpresion(_ lexer: MIOCoreLexer, _ args: [Any]) -> NSExpression
{
    var next_arg_index = 0
    func next_argument() -> Any {
        let v = args[next_arg_index]
        next_arg_index += 1
        return v
    }

    
    let token = lexer.nextToken()
    
    switch token!.type {
    
    case MIOPredicateTokenType.uuidValue.rawValue:
        return MIOExpression(forConstantValue: token!.value)
        
    case MIOPredicateTokenType.stringValue.rawValue:
        let v = String(token!.value.dropLast().dropFirst())
        return MIOExpression(forConstantValue: v)
    
    case MIOPredicateTokenType.numberValue.rawValue:
        if token!.value.contains(".") {
            return MIOExpression(forConstantValue: Double(token!.value))
        }
        else {
            return MIOExpression(forConstantValue: Int(token!.value))
        }

    case MIOPredicateTokenType.booleanValue.rawValue:
        let v = token!.value.lowercased() == "true" ? (true as NSNumber) : (false as NSNumber)
        return MIOExpression(forConstantValue: v)
        
    case MIOPredicateTokenType.arraySymbol.rawValue:
        return MIOExpression(forConstantValue: token!.value)
        
    case MIOPredicateTokenType.nullValue.rawValue:
        return MIOExpression(forConstantValue: nil)

    case MIOPredicateTokenType.classValue.rawValue:
        let v = next_argument()
        return MIOExpression(forConstantValue: v)
        
/*
     case MIOPredicateTokenType.Identifier:
     item.value = token.value;
     item.valueType = MIOPredicateItemValueType.Property;
     break;
     
     */
    default:
        //throw new Error(`MIOPredicate: Error. Unexpected comparator. (${token.value})`);
        break
    }
    
    //TODO: Replace by a throw error
    return NSExpression(expressionType: .anyKey)
}

func MIOPredicateParseOperatorOrFunction(_ lexer: MIOCoreLexer, op: inout NSComparisonPredicate.Operator?, functionType: inout MIOExpression.FunctionType?)
{
    let token = lexer.nextToken()
    
    switch token!.type {
    
    case MIOPredicateTokenType.equalComparator.rawValue:
    op = NSComparisonPredicate.Operator.equalTo
    
    case MIOPredicateTokenType.majorComparator.rawValue:
    op = NSComparisonPredicate.Operator.greaterThan
     
    case MIOPredicateTokenType.majorOrEqualComparator.rawValue:
    op = NSComparisonPredicate.Operator.greaterThanOrEqualTo
         
    case MIOPredicateTokenType.minorComparator.rawValue:
    op = NSComparisonPredicate.Operator.lessThan
     
    case MIOPredicateTokenType.minorOrEqualComparator.rawValue:
    op = NSComparisonPredicate.Operator.lessThanOrEqualTo
     
    case MIOPredicateTokenType.distinctComparator.rawValue:
    op = NSComparisonPredicate.Operator.notEqualTo
         
    case MIOPredicateTokenType.containsComparator.rawValue:
    op = NSComparisonPredicate.Operator.contains
    
    case MIOPredicateTokenType.inComparator.rawValue:
    op = NSComparisonPredicate.Operator.in
      
    case MIOPredicateTokenType.bitwiseAND.rawValue:
    functionType = .bitwiseAnd
        
    case MIOPredicateTokenType.bitwiseOR.rawValue:
    functionType = .bitwiseOr
        
    case MIOPredicateTokenType.bitwiseXOR.rawValue:
    functionType = .bitwiseXor

    case MIOPredicateTokenType.closeParenthesisSymbol.rawValue:
        MIOPredicateParseOperatorOrFunction(lexer, op: &op, functionType: &functionType)
        
    default: break
        //throw new Error(`MIOPredicate: Error. Unexpected comparator. (${token.value})`);
    }
    
}

func MIOPredicateEvaluateObjects(_ objects: [NSManagedObject], using predicate: MIOPredicate) -> [NSManagedObject]
{
    var results:[NSManagedObject] = []
    for obj in objects {
        if MIOPredicateEvaluate(object: obj, using: predicate) {
            results.append(obj)
        }
    }

    return results
}


func MIOPredicateEvaluate(object: NSManagedObject, using predicate: MIOPredicate) -> Bool
{
    if predicate is NSComparisonPredicate {
        let cmp = predicate as! NSComparisonPredicate
        
        var obj_value:Any?
        var value:Any?
        
        if cmp.leftExpression.expressionType == .keyPath {
            obj_value = object.value(forKeyPath: cmp._leftExpression.keyPath)
//            obj_value = object.value(forKey: cmp.leftExpression.keyPath)
        }
        else if cmp.leftExpression.expressionType == .constantValue {
            value = cmp.leftExpression.constantValue
        }
        
        if cmp.rightExpression.expressionType == .keyPath {
            obj_value = object.value(forKeyPath: cmp._leftExpression.keyPath)
//            obj_value = object.value(forKey: cmp.rightExpression.keyPath)
        }
        else if cmp.rightExpression.expressionType == .constantValue {
            value = cmp.rightExpression.constantValue
        }

        if obj_value is UUID { obj_value = (obj_value as! UUID).uuidString.uppercased() }
        
        switch cmp.predicateOperatorType {
            case .equalTo             : return  MIOPredicateEvaluateEqual(     obj_value, value )
            case .notEqualTo          : return !MIOPredicateEvaluateEqual(     obj_value, value )
            case .lessThan            : return  MIOPredicateEvaluateLess(      obj_value, value )
            case .lessThanOrEqualTo   : return  MIOPredicateEvaluateLessEqual( obj_value, value )
            case .greaterThan         : return !MIOPredicateEvaluateLessEqual( obj_value, value )
            case .greaterThanOrEqualTo: return !MIOPredicateEvaluateLess(      obj_value, value )
            case .in                  : return  MIOPredicateEvaluateIn(        obj_value, value )
            default:break
        }

        return false
    }
    else if predicate is NSCompoundPredicate {
        let compound = predicate as! NSCompoundPredicate
        
        switch ( compound.compoundPredicateType ) {
        // TODO: Thow something when not has more than 1 predicate
        case .not: return !MIOPredicateEvaluate( object: object, using: compound.subpredicates[ 0 ] )
        case .and: return compound.subpredicates.reduce(true) { result, predicate in
                result && MIOPredicateEvaluate(object: object, using: predicate)
            }
        case .or : return compound.subpredicates.reduce(true) { result, predicate in
                result || MIOPredicateEvaluate(object: object, using: predicate)
            }
        }
    }
    
    return false
}


func MIOPredicateEvaluateEqual( _ leftValue: Any?, _ rightValue:Any?) -> Bool {

    if leftValue == nil && rightValue == nil { return true }
    if leftValue == nil && rightValue != nil { return false }
    if leftValue != nil && rightValue == nil { return false }

    // Predicate from coredata issue. Coulbe number 1 or 0
    // Check first for Int & Bool Values
    if MIOCoreIsIntValue(leftValue) && MIOCoreIsIntValue(rightValue) {
        return ( MIOCoreInt64Value(leftValue)! == MIOCoreInt64Value(rightValue)! )
    }
    
    switch leftValue! {
    case is String:  return ( leftValue as! String  ) == ( rightValue as! String  )
//    case is Bool:    return ( leftValue as! Bool    ) == ( rightValue as! Bool    )
//    case is Int:     return ( leftValue as! Int     ) == ( rightValue as! Int     )
//    case is Int8:    return ( leftValue as! Int8    ) == ( rightValue as! Int8    )
//    case is Int16:   return ( leftValue as! Int16   ) == ( rightValue as! Int16   )
//    case is Int32:   return ( leftValue as! Int32   ) == ( rightValue as! Int32   )
//    case is Int64:   return ( leftValue as! Int64   ) == ( rightValue as! Int64   )
    case is Float:   return ( leftValue as! Float   ) == ( rightValue as! Float   )
    case is Double:  return ( leftValue as! Double  ) == ( rightValue as! Double  )
    case is Decimal: return ( leftValue as! Decimal ) == ( rightValue as! Decimal )
    case is UUID: return ( (leftValue as! UUID).uuidString ) == ( (rightValue as! UUID).uuidString )
    case is Date:
        if rightValue is String {
            let rightDate = parse_date_or_nil( (rightValue as! String) )
            
            return rightDate == nil ?
                     false
                   : ( leftValue as! Date    ) ==  rightDate!
        }
        
        return (leftValue as! Date) == (rightValue as! Date)

    default:
        print( "[FATAL]: MIOPredicateEvaluate equal cannot compare \(leftValue ?? "nil") with \(rightValue ?? "nil")" )
        return false
    }
}


func MIOPredicateEvaluateLessEqual( _ leftValue: Any?, _ rightValue:Any?) -> Bool {

    if leftValue == nil && rightValue == nil { return true }
    if leftValue == nil && rightValue != nil { return false }
    if leftValue != nil && rightValue == nil { return false }

    if MIOCoreIsIntValue(leftValue) && MIOCoreIsIntValue(rightValue) {
        return ( MIOCoreInt64Value(leftValue)! <= MIOCoreInt64Value(rightValue)! )
    }

    switch leftValue! {
    case is String:  return ( leftValue as! String  ) <= ( rightValue as! String  )
//    case is Int:     return ( leftValue as! Int     ) <= ( rightValue as! Int     )
//    case is Int8:    return ( leftValue as! Int8    ) <= ( rightValue as! Int8    )
//    case is Int16:   return ( leftValue as! Int16   ) <= ( rightValue as! Int16   )
//    case is Int32:   return ( leftValue as! Int32   ) <= ( rightValue as! Int32   )
//    case is Int64:   return ( leftValue as! Int64   ) <= ( rightValue as! Int64   )
    case is Float:   return ( leftValue as! Float   ) <= ( rightValue as! Float   )
    case is Double:  return ( leftValue as! Double  ) <= ( rightValue as! Double  )
    case is Decimal: return ( leftValue as! Decimal ) <= ( rightValue as! Decimal )
    case is UUID: return ( (leftValue as! UUID).uuidString ) <= ( (rightValue as! UUID).uuidString )
    case is Date:
        if rightValue is String {
            let rightDate = parse_date_or_nil( (rightValue as! String) )
            
            return rightDate == nil ?
                     false
                   : (leftValue as! Date) <=  rightDate!
        }
        
        return (leftValue as! Date) <= (rightValue as! Date)

    default: return false
    }
}


func MIOPredicateEvaluateLess( _ leftValue: Any?, _ rightValue:Any?) -> Bool {

    if leftValue == nil && rightValue == nil { return true }
    if leftValue == nil && rightValue != nil { return false }
    if leftValue != nil && rightValue == nil { return false }

    if MIOCoreIsIntValue(leftValue) && MIOCoreIsIntValue(rightValue) {
        return ( MIOCoreInt64Value(leftValue)! < MIOCoreInt64Value(rightValue)! )
    }
    
    switch leftValue! {
    case is String:  return ( leftValue as! String  ) < ( rightValue as! String  )
//    case is Int:     return ( leftValue as! Int     ) < ( rightValue as! Int     )
//    case is Int8:    return ( leftValue as! Int8    ) < ( rightValue as! Int8    )
//    case is Int16:   return ( leftValue as! Int16   ) < ( rightValue as! Int16   )
//    case is Int32:   return ( leftValue as! Int32   ) < ( rightValue as! Int32   )
//    case is Int64:   return ( leftValue as! Int64   ) < ( rightValue as! Int64   )
    case is Float:   return ( leftValue as! Float   ) < ( rightValue as! Float   )
    case is Double:  return ( leftValue as! Double  ) < ( rightValue as! Double  )
    case is Decimal: return ( leftValue as! Decimal ) < ( rightValue as! Decimal )
    case is UUID: return ( (leftValue as! UUID).uuidString ) < ( (rightValue as! UUID).uuidString )
    case is Date:
        if rightValue is String {
            let rightDate = parse_date_or_nil( (rightValue as! String) )
            
            return rightDate == nil ?
                     false
                   : (leftValue as! Date) <  rightDate!
        }
        
        return (leftValue as! Date) < (rightValue as! Date)

    default: return false
    }
}

func MIOPredicateEvaluateIn( _ leftValue: Any?, _ rightValue:Any?) -> Bool {
    if leftValue == nil && rightValue == nil { return true }
    if leftValue == nil && rightValue != nil { return false }
    if leftValue != nil && rightValue == nil { return false }

    let value = String((rightValue as! String).dropFirst().dropLast())
                    .components(separatedBy: ",")
                    .map { inferType( String( $0.trimmingCharacters(in: .whitespaces) ) ) }

    
    if let str_list = value as? [String] {
        if let lv = leftValue as? UUID {
            return (str_list).contains( lv.uuidString )
        }
        else {
            return (str_list).contains( leftValue as! String )
        }
    }
    else if let uuid_list = value as? [UUID] {
        if let lv = leftValue as? UUID {
            return (uuid_list).contains( lv )
        }
        else {
            return (uuid_list).contains( UUID(uuidString: leftValue as! String )! )
        }
    }

    
    return (value as! [Int32]).contains( MIOCoreInt32Value( leftValue!)! )
}


func inferType ( _ value: String ) -> Any {
    if value.starts(with: "\"" ) {
        return value.replacingOccurrences(of: "\"", with: "")
    }
    else if value.starts(with: "'" ) {
        return value.replacingOccurrences(of: "'", with: "")
    }
    else if let uuid = UUID(uuidString: value) {
        return uuid
    }
    
    return MIOCoreInt32Value( value )!
}

