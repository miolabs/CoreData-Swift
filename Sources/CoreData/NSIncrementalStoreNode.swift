//
//  NSIncrementalStoreNode.swift
//  
//
//  Created by Javier Segura Perez on 15/05/2020.
//

import Foundation


open class NSIncrementalStoreNode : NSObject
{
    // Returns an object initialized with the following values
    // objectID -> The NSManagedObjectID corresponding to the object whose values are cached
    //
    // values -> A dictionary containing the values persisted in an external store with keys corresponding to the names of the NSPropertyDescriptions
    //      in the NSEntityDescription described by the NSManagedObjectID.  Unknown or unmodeled keys will be stripped out.
    //
    //        For attributes: an immutable value (NSNumber, NSString, NSData etc).  Missing attribute keys will assume a nil value.
    //
    //        For to-one relationships: the NSManagedObjectID of the related object or NSNull for nil relationship values. A missing key will be resolved lazily through calling
    //          -newValueForRelationship:forObjectWithID:withContext:error: on the NSPersistentStore.  Lazy resolution for to-ones is discouraged.
    //
    //      For to-many relationships: an NSArray or NSSet containing the NSManagedObjectIDs of the related objects.  Empty to-many relationships must
    //          be represented by an empty non-nil collection.  A missing key will be resolved lazily through calling.  Lazy resolution for to-manys is encouraged.
    //          -newValueForRelationship:forObjectWithID:withContext:error: on the NSPersistentStore
    //
    // version -> The revision number of this state; used for conflict detection and merging
    public init(objectID: NSManagedObjectID, withValues values: [String : Any], version: UInt64) {
        _objectID = objectID
        _version = version
        _values = values
    }

    
    // Update the values and version to reflect new data being saved to or loaded from the external store.
    // The values dictionary is in the same format as the initializer
    var _values:[String:Any]
    open func update(withValues values: [String : Any], version: UInt64) {
        _values = values.merging(_values, uniquingKeysWith: { (first, _) in first })
        _version = version
    }

    var _objectID:NSManagedObjectID
    // Return the object ID that identifies the data stored by this node
    open var objectID: NSManagedObjectID { get { return _objectID } }

    
    var _version:UInt64 = 0
    // Return the version of data in this node.
    open var version: UInt64 { get { return _version } }

    
    // May return NSNull for to-one relationships.  If a relationship is nil, clients should  invoke -newValueForRelationship:forObjectWithID:withContext:error: on the NSPersistentStore
    open func value(for prop: NSPropertyDescription) -> Any? {
        return _values[prop.name]
    }
    
    open func value(for name: String) -> Any? {
        return _values[name]
    }
    
}

/*
 
 let value = this._values[property.name];

        if (property instanceof MIORelationshipDescription) {
            let rel = property as MIORelationshipDescription;
            if (value == null) {
                value = this._values[rel.serverName];
            }
            return value;
        }
        else if (property instanceof MIOAttributeDescription) {
            let attr = property as MIOAttributeDescription;
            let type = attr.attributeType;

            if (value == null){
                value = this._values[attr.serverName];
            }
    
            if (type == MIOAttributeType.Boolean) {
                if (typeof (value) === "boolean") {
                    return value;
                }
                else if (typeof (value) === "string") {
                    let lwValue = value.toLocaleLowerCase();
                    if (lwValue == "yes" || lwValue == "true" || lwValue == "1")
                        return true;
                    else
                        return false;
                }
                else {
                    let v = value > 0 ? true : false;
                    return v;
                }
            }
            else if (type == MIOAttributeType.Integer) {
                let v = parseInt(value);
                return isNaN(v) ? null : v;
            }
            else if (type == MIOAttributeType.Float || type == MIOAttributeType.Number) {
                let v = parseFloat(value);
                return isNaN(v) ? null : v;
            }
            else if (type == MIOAttributeType.String) {
                return value;
            }
            else if (type == MIOAttributeType.Date) {
                let date = _MIOIncrementalStoreNodeDateTransformer.sdf.dateFromString(value);
                return date;
            }
        }
        
        return value;
 */
