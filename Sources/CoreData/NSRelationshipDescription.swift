//
//  MIORelationshipDescription.swift
//  DLAPIServer
//
//  Created by Javier Segura Perez on 21/05/2019.
//

import Foundation

public enum NSDeleteRule : UInt
{
    case noActionDeleteRule = 0
    case nullifyDeleteRule = 1
    case cascadeDeleteRule = 2
    case denyDeleteRule = 3
}

public class NSRelationshipDescription : NSPropertyDescription
{
    unowned(unsafe) open var destinationEntity: NSEntityDescription?
    unowned(unsafe) open var inverseRelationship: NSRelationshipDescription?
    
    // Min and max count indicate the number of objects referenced (1/1 for a to-one relationship, 0 for the max count means undefined) - note that the counts are only enforced if the relationship value is not nil/"empty" (so as long as the relationship value is optional, there might be zero objects in the relationship, which might be less than the min count)
    open var maxCount:Int = 0
    open var minCount: Int = 0

    open var deleteRule = NSDeleteRule.noActionDeleteRule
    
    open var isToMany: Bool { get { return maxCount == 1 ? false : true} } // convenience method to test whether the relationship is to-one or to-many
    
    var _destinationEntityName:String?
    open var destinationEntityName:String { get { return _destinationEntityName! } set { _destinationEntityName = newValue } }
    var inverseName:String?
    var inverseEntityName:String?
    
    public override init() {
        super.init()
    }
    
    init(name:String, destinationEntityName:String, toMany:Bool, optional: Bool, inverseName:String?, inverseEntityName:String?){
        self.maxCount = toMany ? 2 : 1
        _destinationEntityName = destinationEntityName
        self.inverseName = inverseName
        self.inverseEntityName = inverseEntityName
        super.init(name: name, optional: optional, transient: false)
    }
        
}
