//
//  MIOEntityDescription.swift
//  
//
//  Created by Javier Segura Perez on 21/05/2019.
//

import Foundation

import MIOCore

open class NSEntityDescription : NSObject
{
    public override init() {}
    
    open class func entity(forEntityName entityName: String, in context: NSManagedObjectContext) -> NSEntityDescription? {
        return context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName]
    }

    open class func insertNewObject(forEntityName entityName: String, into context: NSManagedObjectContext) -> NSManagedObject {
        let model = context.persistentStoreCoordinator!.managedObjectModel
        //FIX: let objectClass = NSClassFromString(entityName) as! NSManagedObject.Type -> Doesn't work on Linux
        let objectClass = _MIOCoreClassFromString(entityName) as! NSManagedObject.Type
        return objectClass.init(entity: model.entitiesByName[entityName]!, insertInto: context)
    }
    
    weak var _model:NSManagedObjectModel!
    unowned(unsafe) open var managedObjectModel: NSManagedObjectModel { get { return _model } }
    
    open var managedObjectClassName: String!
    
    var _name:String?
    open var name: String? { get { _name } }
    
    var _isAbstract = false
    open var isAbstract: Bool { get { return _isAbstract } }
    
    var _subentitiesByName:[String : NSEntityDescription] = [:]
    open var subentitiesByName: [String : NSEntityDescription] { get { return _subentitiesByName } }

    open var subentities: [NSEntityDescription] = []

    open weak var _superentity:NSEntityDescription?
    unowned(unsafe) open var superentity: NSEntityDescription? { get { return _superentity } }

    var _propertiesByName:[String : NSPropertyDescription] = [:]
    open var propertiesByName: [String : NSPropertyDescription] { get { return _propertiesByName } }

    open var properties: [NSPropertyDescription] = []
     
    var _userInfo: [AnyHashable : Any]?
    open var userInfo: [AnyHashable : Any]? {
        get { return _userInfo }
        set {
            if _userInfo == nil {
                _userInfo = newValue
            }
            else if newValue != nil {
                for (key, value) in newValue! {
                    _userInfo![key] = value
                }
            }
        }
    }

    // convenience methods to get the most common (and most relevant) types of properties for an entity
    var _attributesByName:[String : NSAttributeDescription] = [:]
    open var attributesByName: [String : NSAttributeDescription] { get { return _attributesByName } }

    var _relationshipsByName:[String : NSRelationshipDescription] = [:]
    open var relationshipsByName: [String : NSRelationshipDescription] { get { return _relationshipsByName } }

    /* Returns/sets the version hash modifier for the entity.  This value is included in the version hash for the entity, allowing developers to mark/denote an entity as being a different "version" than another, even if all of the values which affect persistence are equal.  (Such a difference is important in cases where the structure of an entity is unchanged, but the format or content of data has changed.)
    */
    open var versionHashModifier: String? = nil
    
    open var indexes: [NSFetchIndexDescription] = []
    
    open func relationships(forDestination entity: NSEntityDescription) -> [NSRelationshipDescription] {
        
        var relations = [NSRelationshipDescription]()
        for (_, rel) in relationshipsByName {
            if rel.destinationEntityName == entity.name {
                relations.append(rel)
            }
        }
            
        return relations
    }

    var _toManyRelationshipKeys: [String] = []
    var _toOneRelationshipKeys: [String] = []
    
    #if os(Linux)
    open var toManyRelationshipKeys: [ String ] { get { return _toManyRelationshipKeys } }
    open var toOneRelationshipKeys: [ String ] { get { return _toOneRelationshipKeys } }
    #else
    open override var toManyRelationshipKeys: [ String ] { get { return _toManyRelationshipKeys } }
    open override var toOneRelationshipKeys: [ String ] { get { return _toOneRelationshipKeys } }
    #endif
        
    init(entityName:String, parentEntity:NSEntityDescription?, isAbstract:String, managedObjectModel model:NSManagedObjectModel) {
        _name = entityName
        managedObjectClassName = entityName
        _isAbstract = (isAbstract == "yes")
        _model = model
        super.init()
    }
    
    open var parentEntityName:String?
        
    @discardableResult func addAttribute(name:String, type:NSAttributeType, defaultValue:Any?, optional:Bool, transient:Bool) -> NSAttributeDescription {
        let attr = NSAttributeDescription(name: name, type: type, defaultValue: defaultValue, optional: optional, transient: transient)
        attr._entity = self
        properties.append(attr)
        _propertiesByName[name] = attr
        _attributesByName[name] = attr
        
        return attr
    }

    @discardableResult func addRelationship(name:String, destinationEntityName:String, toMany:Bool, optional:Bool, inverseName:String?, inverseEntityName:String?, deleteRule:NSDeleteRule) -> NSRelationshipDescription {
        let rel = NSRelationshipDescription(name: name, destinationEntityName: destinationEntityName, toMany: toMany, optional: optional, inverseName:inverseName, inverseEntityName: inverseEntityName)        
        rel._entity = self
        properties.append(rel)
        _propertiesByName[name] = rel
        _relationshipsByName[name] = rel
        if rel.isToMany {
            _toManyRelationshipKeys.append( name )
        } else {
            _toOneRelationshipKeys.append( name )
        }
        rel.deleteRule = deleteRule
        
        return rel
    }
    
    var isBuilt = false
    open func build() { 

        if isBuilt { return }
        isBuilt = true
        
        if let parentEntityName = parentEntityName {
            let parentEntity = managedObjectModel.entitiesByName[parentEntityName]
            _superentity = parentEntity
            parentEntity!.subentities.append(self)
            parentEntity!.build()
            
            // NOTE: We don't want to progate the user info configuration to it's own children.
            // For example if the base class has the property TableHasiTownTable... we dont want every children
            // has teh same property.
//            if userInfo != nil {
//               userInfo!.merge( parentEntity!.userInfo ?? [:] ){ (old,_new) in old }
//            }
            
            for (_, prop) in parentEntity!.propertiesByName {

                if prop is NSAttributeDescription {
                    let attr = prop as! NSAttributeDescription
                    let new_attr = addAttribute(name: attr.name, type: attr.attributeType, defaultValue: attr.defaultValue, optional: attr.isOptional, transient: attr.isTransient)
                    new_attr.userInfo = attr.userInfo
                }
                else if prop is NSRelationshipDescription {
                    let rel = prop as! NSRelationshipDescription
                    let new_rel = addRelationship(name: rel.name, destinationEntityName: rel.destinationEntityName, toMany: rel.isToMany, optional: rel.isOptional, inverseName: rel.inverseName, inverseEntityName: rel.inverseEntityName, deleteRule: rel.deleteRule)
                    new_rel.userInfo = rel.userInfo
                }
            }
        }
        
        for (_, rel) in relationshipsByName {
            if rel.destinationEntity == nil {
                rel.destinationEntity = managedObjectModel.entitiesByName[rel.destinationEntityName]
            }
            
            if rel.inverseName != nil && rel.inverseEntityName != nil {
                let inverseEntity = managedObjectModel.entitiesByName[rel.inverseEntityName!]
                let inverseRelation = inverseEntity?.relationshipsByName[rel.inverseName!]
                rel.inverseRelationship = inverseRelation
            }
        }
    }
    
    //
    // MARK: Debug
    //
    
    // Example:
//    (<NSEntityDescription: 0x102908dd0>) name SimpleEntity, managedObjectClassName SimpleEntity, renamingIdentifier SimpleEntity, isAbstract 0, superentity name (null), properties {
//        identifier = "(<NSAttributeDescription: 0x102908790>), name identifier, isOptional 0, isTransient 0, entity SimpleEntity, renamingIdentifier identifier, validation predicates (\n), warnings (\n), versionHashModifier (null)\n userInfo {\n}, attributeType 1100 , attributeValueClassName NSUUID, defaultValue (null), preservesValueInHistoryOnDeletion NO";
//        name = "(<NSAttributeDescription: 0x1029075a0>), name name, isOptional 0, isTransient 0, entity SimpleEntity, renamingIdentifier name, validation predicates (\n), warnings (\n), versionHashModifier (null)\n userInfo {\n}, attributeType 700 , attributeValueClassName NSString, defaultValue (null), preservesValueInHistoryOnDeletion NO";
//        type = "(<NSAttributeDescription: 0x10290da60>), name type, isOptional 0, isTransient 0, entity SimpleEntity, renamingIdentifier type, validation predicates (\n), warnings (\n), versionHashModifier (null)\n userInfo {\n}, attributeType 100 , attributeValueClassName NSNumber, defaultValue 0, preservesValueInHistoryOnDeletion NO";
//    }, subentities {
//    }, userInfo {
//    }, versionHashModifier (null), uniquenessConstraints (
//    )
    open override var debugDescription: String {
        get {
            var str = ""
            str += "<NSEntityDescription: \(Unmanaged.passUnretained(self).toOpaque())>\n"
            str += " name: \(name!),\n"
            str += " managedObjectClassName: \(name!)\n"
            str += " renamingIdentifier: \(name!)\n"
            str += " isAbstract: \(isAbstract ? "true" : "false")\n"
            str += " superentity name: \(superentity?.name ?? "(null)")\n"
            str += " properties: { TODO }\n"
            str += " subentities: { TODO }\n"
            str += " userInfo: { TODO }\n"
            str += " versionHashModifier: \(versionHashModifier ?? "(null)") \n"
            str += " uniquenessConstraints: ( TODO )\n"
            
            return str
        }
    }
}
