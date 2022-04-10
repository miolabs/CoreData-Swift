//
//  NSManagedObject.swift
//  
//
//  Created by Javier Segura Perez on 12/05/2020.
//

import Foundation

open class NSManagedObject : NSObject
{
    /*  Distinguish between changes that should and should not dirty the object for any key unknown to Core Data.  10.5 & earlier default to NO.  10.6 and later default to YES. */
    /*    Similarly, transient attributes may be individually flagged as not dirtying the object by adding +(BOOL)contextShouldIgnoreChangesFor<key> where <key> is the property name. */
    //open class var contextShouldIgnoreUnmodeledPropertyChanges: Bool { get }
    
    
    /* The Entity represented by this subclass. This method is only legal to call on subclasses of NSManagedObject that represent a single entity in the model.
     */
    //    open class func entity() -> NSEntityDescription {
    //        return _entity
    //    }
    
    /* A new fetch request initialized with the Entity represented by this subclass. This property's getter is only legal to call on subclasses of NSManagedObject that represent a single entity in the model.
     */
    //    open class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
    //
    //    }
    
    
    /* The designated initializer. */
    public required init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        _managedObjectContext = context
        _objectID = NSManagedObjectID(WithEntity: entity, referenceObject: nil)
        super.init()
        
        context?.insert(self)
        _setDefaultValues()
                
        awakeFromFetch()
    }
    
    func _setDefaultValues() {
        //let attributes = this.entity.attributesByName;
        for prop in entity.properties {
            if prop is NSRelationshipDescription { continue }
            
            let attr = prop as! NSAttributeDescription
            let value = attr.defaultValue

            if value == nil { continue }
            setValue(value, forKey: prop.name)
        }
    }
    
    public required override init() {
        super.init()
    }
    
    /* Returns a new object, inserted into managedObjectContext. This method is only legal to call on subclasses of NSManagedObject that represent a single entity in the model.
     */
    //    public convenience init(context moc: NSManagedObjectContext) {
    //
    //    }
    
    weak var _managedObjectContext:NSManagedObjectContext?
    // identity
    unowned(unsafe) open var managedObjectContext: NSManagedObjectContext? { get { return _managedObjectContext } }
    
    open var entity: NSEntityDescription { get {return objectID.entity } }
    
    var _objectID:NSManagedObjectID!
    open var objectID: NSManagedObjectID { get { return _objectID } }
    
    
    // state - methods
    var _isInserted = false
    open var isInserted: Bool { get { return _isInserted } }
    
    var _isUpdated = false
    open var isUpdated: Bool { get { return _isUpdated } }
    
    var _isDeleted = false
    open var isDeleted: Bool { get { return _isDeleted } }
    
    var _hasChanges = false
    open var hasChanges: Bool { get { return _hasChanges } }
    
    
    /* returns YES if any persistent properties do not compare isEqual to their last saved state.  Relationship faults will not be unnecessarily fired.  This differs from the existing -hasChanges method which is a simple dirty flag and also includes transient properties */
    //open var hasPersistentChangedValues: Bool { get }
    
    
    var _isFault = true
    // this information is useful in many situations when computations are optional - this can be used to avoid growing the object graph unnecessarily (which allows to control performance as it can avoid time consuming fetches from databases)
    open var isFault: Bool { get { return _isFault } }
    
    
    // returns a Boolean indicating if the relationship for the specified key is a fault.  If a value of NO is returned, the resulting relationship is a realized object;  otherwise the relationship is a fault.  If the specified relationship is a fault, calling this method does not result in the fault firing.
    var relationShipsNamedNotFault:Set<String> = Set()
    open func hasFault(forRelationshipNamed key: String) -> Bool { return !relationShipsNamedNotFault.contains(key) }
    
    
    /* returns an array of objectIDs for the contents of a relationship.  to-one relationships will return an NSArray with a single NSManagedObjectID.  Optional relationships may return an empty NSArray.  The objectIDs will be returned in an NSArray regardless of the type of the relationship.  */
    //open func objectIDs(forRelationshipNamed key: String) -> [NSManagedObjectID]
    
    
    /* Allow developers to determine if an object is in a transitional phase when receiving a KVO notification.  Returns 0 if the object is fully initialized as a managed object and not transitioning to or from another state */
    //open var faultingState: Int { get }
    
    
    // lifecycle/change management (includes key-value observing methods)
    open func willAccessValue(forKey key: String?) { // read notification
        
    }
    
    open func didAccessValue(forKey key: String?) { // read notification (together with willAccessValueForKey used to maintain inverse relationships, to fire faults, etc.) - each read access has to be wrapped in this method pair (in the same way as each write access has to be wrapped in the KVO method pair)
        
        
    }
    
    // KVO change notification
    #if os(Linux)
    open func willChangeValue(forKey key: String) {}
    open func didChangeValue(forKey key: String) {}
    #endif
    
    //    open func willChangeValue(forKey inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, using inObjects: Set<AnyHashable>)
    //
    //    open func didChangeValue(forKey inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, using inObjects: Set<AnyHashable>)
    
    
    // invoked after a fetch or after unfaulting (commonly used for computing derived values from the persisted properties)
    open func awakeFromFetch() {
        
    }
    
    
    // invoked after an insert (commonly used for initializing special default/initial settings)
    open func awakeFromInsert() {
        
    }
    
    
    /* Callback for undo, redo, and other multi-property state resets */
    //open func awake(fromSnapshotEvents flags: NSSnapshotEventType)
    
    
    /* Callback before delete propagation while the object is still alive.  Useful to perform custom propagation before the relationships are torn down or reconfigure KVO observers. */
    open func prepareForDeletion() {
        
    }
    
    // commonly used to compute persisted values from other transient/scratchpad values, to set timestamps, etc. - this method can have "side effects" on the persisted values
    open func willSave() {
        
    }
    
    
    // commonly used to notify other objects after a save
    open func didSave() {
        
    }
    
    
    // invoked automatically by the Core Data framework before receiver is converted (back) to a fault.  This method is the companion of the -didTurnIntoFault method, and may be used to (re)set state which requires access to property values (for example, observers across keypaths.)  The default implementation does nothing.
    open func willTurnIntoFault() {
        
    }
    
    
    // commonly used to clear out additional transient values or caches
    open func didTurnIntoFault() {
        
    }
    
    
    // value access (includes key-value coding methods)
    
    // KVC - overridden to access generic dictionary storage unless subclasses explicitly provide accessors
    #if os(Linux)
    open func value(forKey key: String) -> Any? { return _value(forKey:key)}
    #else
    open override func value(forKey key: String) -> Any? { return _value(forKey:key) }
    #endif
    
    open func _value(forKey key: String) -> Any? {
        
        guard let property = entity.propertiesByName[key] else {
            #if os(Linux)
            return nil
            #else
            return super.value(forKey:key)
            #endif
        }
        
        willAccessValue(forKey:key)
        
        var value:Any?
        
        if property is NSAttributeDescription {
            
            if _changedValues.keys.contains(key) {
                value = _changedValues[key]
            }
            else {
                value = storedValues[key]
            }
        }
        else if property is NSRelationshipDescription {
            let relationship = property as! NSRelationshipDescription
            if relationship.isToMany == false {
                if _changedValues.keys.contains(key) {
                    if let objID = _changedValues[key] as? NSManagedObjectID {
                        value = try! managedObjectContext!.existingObject(with: objID)
                    }
                }
                else {
                    if let objID = primitiveValue(forKey:key) as? NSManagedObjectID {
                        value = try! managedObjectContext!.existingObject(with: objID)
                    }
                }
            }
            else {
                let values:Set<NSManagedObjectID>?
                if _changedValues.keys.contains(key) {
                    values = _changedValues[key] as? Set<NSManagedObjectID>
                } 
                else {
                    values = primitiveValue(forKey:key) as? Set<NSManagedObjectID>
                }
                
                value = Set( (values ?? Set()).map{ try! managedObjectContext!.existingObject(with: $0 ) } )
            }
        }
        
        didAccessValue(forKey:key)
        
        return value is NSNull ? nil : value
    }
    
    
    // KVC - overridden to access generic dictionary storage unless subclasses explicitly provide accessors
    #if os(Linux)
    open func setValue(_ value: Any?, forKey key: String) { _setValue(value, forKey: key) }
    #else
    open override func setValue(_ value: Any?, forKey key: String) { _setValue(value, forKey: key) }
    #endif
    
    open func _setValue(_ value: Any?, forKey key: String, ignoreInverses: Bool = false) {

        guard let property = entity.propertiesByName[key] else {
            #if os(OSX)
            super.setValue(value, forKey: key)
            #endif
            return
        }

        willChangeValue(forKey: key)

        if (value == nil) {
            _changedValues[key] = NSNull()
        }
        else if property is NSRelationshipDescription {
            let relationship = property as! NSRelationshipDescription
            if relationship.isToMany == false {
                let obj = value as! NSManagedObject
                _changedValues[key] = obj.objectID
                
                addInverseRelationship( relationship, obj, ignoreInverses )
            }
            else {
                if let objects = value as? Set<NSManagedObject> {
                    var objIDs:Set<NSManagedObjectID> = Set( )
                    for obj in objects {
                        addInverseRelationship( relationship, obj, ignoreInverses )
                        objIDs.insert(obj.objectID)
                    }
                    _changedValues[key] = objIDs
                }
                else {
                    _changedValues[key] = NSNull()
                }
            }
        }
        else {
            _changedValues[key] = value
        }

        didChangeValue(forKey: key)

        managedObjectContext?.refresh(self, mergeChanges: false)
    }
    
    // primitive methods give access to the generic dictionary storage from subclasses that implement explicit accessors like -setName/-name to add custom document logic
    open func primitiveValue(forKey key: String) -> Any? {
        if hasFault(forRelationshipNamed: key) && objectID.persistentStore != nil {
            unfaultRelationshipNamed( key, fromStore: objectID.persistentStore! )
        }
        return storedValues[key]
    }
    
    open func setPrimitiveValue(_ value: Any?, forKey key: String) {
        _storedValues[key] = value
    }
    
    // returns a dictionary of the last fetched or saved keys and values of this object.  Pass nil to get all persistent modeled properties.
    open func committedValues(forKeys keys: [String]?) -> [String : Any] {
        if keys == nil { return storedValues }
            
        var values:[String: Any] = [:]
        for key in keys! {
            if entity.propertiesByName[key] is NSRelationshipDescription {
                if hasFault(forRelationshipNamed: key) && objectID.persistentStore != nil {
                    unfaultRelationshipNamed(key, fromStore: objectID.persistentStore!)
                }
            }
            if let v = storedValues[key] as? [NSManagedObjectID] {
                values[key] = Set(v.map{ try? managedObjectContext!.existingObject(with: $0 ) } )
            }
            else if let v = storedValues[key] as? [NSManagedObject] {
                values[key] = Set(v)
            }
            else if let v = storedValues[key] as? Set<NSManagedObjectID> {
                values[key] = Set(v.map{ try? managedObjectContext!.existingObject(with: $0 ) } )
            }
            else if let v = storedValues[key] as? Set<NSManagedObject> {
                values[key] = v
            }
            else {
                values[key] = Set<NSManagedObject>()
            }
        }
        return values
    }
    
    
    // returns a dictionary with the keys and (new) values that have been changed since last fetching or saving the object (this is implemented efficiently without firing relationship faults)
    var _changedValues:[String: Any] = [:]
    open func changedValues() -> [String : Any] {
        return Dictionary( uniqueKeysWithValues: _changedValues.map{ (k,v) in
            if let relation = entity.relationshipsByName[ k ] {
                if relation.isToMany {
                    if v is NSNull { return ( k, Set<NSManagedObjectID>() ) }
                    return (k, Set( (v as! Set<NSManagedObjectID>).map{ try? managedObjectContext!.existingObject(with: $0 ) } ) )
                } else {
                    if v is NSNull { return ( k, v ) }
                    return (k, try! managedObjectContext!.existingObject(with: v as! NSManagedObjectID) )
                }
            } else {
                return (k,v)
            }
        } )
    }
    
    
    //open func changedValuesForCurrentEvent() -> [String : Any]
    
    
    // validation - in addition to KVC validation managed objects have hooks to validate their lifecycle state; validation is a critical piece of functionality and the following methods are likely the most commonly overridden methods in custom subclasses
    //    open override func validateValue(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey key: String) throws { // KVC
    //    }
    
    open func validateForDelete() throws {
        
    }
    
    open func validateForInsert() throws {
        
    }
    
    open func validateForUpdate() throws {
        
    }
    
    //
    // Custom methods
    //
    
    func setIsFault(_ value:Bool) {
        
        if value == _isFault { return }
        
        willChangeValue(forKey: "hasChanges")
        willChangeValue(forKey:"isFault")
        _isFault = value
        if value == true {
            _storedValues = [:]
            relationShipsNamedNotFault = Set()
        }
        didChangeValue(forKey: "isFault")
        didChangeValue(forKey: "hasChanges")
    }
    
    var _storedValues: [String:Any] = [:]
    var storedValues: [String : Any] {
        get {
            if objectID.isTemporaryID == true { return [:] }
            if objectID.persistentStore == nil { return [:] }
            
            if _isFault == false { return _storedValues }
            
            unfaultAttributes(fromStore: objectID.persistentStore!)
            setIsFault(false)
            
            return _storedValues
        }
    }
    
    func unfaultAttributes(fromStore store:NSPersistentStore?) {
        //if _isDeleted == true { return }
        
        guard let incrementalStore = store as? NSIncrementalStore else { return }
        
        _storedValues = [:]
        
        let node = try? incrementalStore.newValuesForObject(with: objectID, with: managedObjectContext!)
        if node == nil { return }
        
        for (key, attr) in entity.attributesByName {
            let value = node!.value(for: attr)
            _storedValues[key] = value
        }
        
        _isFault = false
        // Force to unfault all relationships
        // relationShipsNamedNotFault = Set()
    }
    
    func unfaultRelationshipNamed(_ key:String, fromStore store:NSPersistentStore?) {
        //if _isDeleted == true { return }
        
        if store == nil { return }
        if isFault { unfaultAttributes(fromStore: store! ) }
        
        relationShipsNamedNotFault.insert(key)
        
        guard let relation = entity.relationshipsByName[key] else { return }
        guard let incrementalStore = store as? NSIncrementalStore else { return }
        
        let value = try? incrementalStore.newValue(forRelationship: relation, forObjectWith: objectID, with: managedObjectContext)
        if value == nil { return }

        _storedValues[relation.name] = relation.isToMany ? Set( value! as! [NSManagedObjectID] ) : value!
    }
    
    func _didCommit() {
        _changedValues = [:]
        setIsFault(true)
    }
    
    func _setIsInserted(_ value:Bool) {
        willChangeValue(forKey: "hasChanges")
        willChangeValue(forKey: "isInserted")
        _isInserted = value
        didChangeValue(forKey: "isInserted")
        didChangeValue(forKey: "hasChanges")
    }
            
    func _setIsUpdated(_ value:Bool) {        
        willChangeValue(forKey: "hasChanges")
        willChangeValue(forKey: "isUpdated")
        _isUpdated = value
        didChangeValue(forKey: "isUpdated")
        didChangeValue(forKey: "hasChanges")
    }

    func _setIsDeleted(_ value:Bool) {
        willChangeValue(forKey: "hasChanges")
        willChangeValue(forKey: "isDeleted")
        _isDeleted = value
        deleteInverseRelationships()
        _isDeleted = value
        didChangeValue(forKey: "isDeleted")
        didChangeValue(forKey: "hasChanges")
    }

    open func _addObject(_ object:NSManagedObject, forKey key:String, ignoreInverses: Bool = false ) {
        if hasFault(forRelationshipNamed: key) == true { unfaultRelationshipNamed(key, fromStore: objectID.persistentStore) }
        
        var objIDs:Set<NSManagedObjectID> = _changedValues[key] as? Set<NSManagedObjectID> ??
                                            storedValues[key] as? Set<NSManagedObjectID> ??
                                            Set( )
        
        addInverseRelationship( entity.relationshipsByName[ key ]!, object, ignoreInverses )
        
        objIDs.insert(object.objectID)
        _changedValues[key] = objIDs
        managedObjectContext?.refresh(self, mergeChanges: false)
    }

    open func _removeObject(_ object:NSManagedObject, forKey key:String, ignoreInverses: Bool = false, refresh: Bool = true) {
        if hasFault(forRelationshipNamed: key) == true { unfaultRelationshipNamed(key, fromStore: objectID.persistentStore) }
        
        var objIDs:Set<NSManagedObjectID> = _changedValues[key] as? Set<NSManagedObjectID> ??
                                            storedValues[key] as? Set<NSManagedObjectID> ??
                                            Set( )

        removeInverseRelationship( entity.relationshipsByName[ key ]!, object, ignoreInverses )
        
        objIDs.remove( object.objectID )

        _changedValues[key] = objIDs
        if refresh { managedObjectContext?.refresh(self, mergeChanges: false) }
    }

    
    func addInverseRelationship ( _ relationship: NSRelationshipDescription, _ obj: NSManagedObject, _ ignoreInverses: Bool ) {
        if relationship.inverseRelationship == nil || ignoreInverses { return }
        
        if relationship.inverseRelationship!.isToMany == false {
            obj._setValue( self, forKey: relationship.inverseName!, ignoreInverses: true )
        } else {
            obj._addObject( self, forKey: relationship.inverseName!, ignoreInverses: true )
        }
    }
    
    func removeInverseRelationship ( _ relationship: NSRelationshipDescription, _ obj: NSManagedObject, _ ignoreInverses: Bool ) {
        if relationship.inverseRelationship == nil || ignoreInverses { return }
        
        if relationship.inverseRelationship!.isToMany == false {
            obj._setValue( nil, forKey: relationship.inverseName!, ignoreInverses: true )
        } else {
            obj._removeObject( self, forKey: relationship.inverseName!, ignoreInverses: true )
        }
    }
    
    func deleteInverseRelationships() {
        
        for (_, rel) in entity.relationshipsByName {
            
//            if rel.inverseName == nil { continue }
            
            switch rel.deleteRule {
            case .cascadeDeleteRule: deleteByCascade(fromRelationship: rel)
            case .nullifyDeleteRule: deleteByNullify(fromRelationship: rel)
            default: break
            }
        }
    }
    
    func deleteByNullify(fromRelationship relationship: NSRelationshipDescription){
        
        if relationship.isToMany == false {
            guard let obj = value(forKey: relationship.name) as? NSManagedObject else { return }
            if obj.isDeleted == false { obj._nullify_inverse_relation( relationship.inverseRelationship, self ) }
        }
        else {
            let objects = value(forKey: relationship.name) as! Set<NSManagedObject>
            for obj in objects {
                if obj.isDeleted == false { obj._nullify_inverse_relation( relationship.inverseRelationship, self ) }
            }
        }
    }
    
    func _nullify_inverse_relation (_ relationship: NSRelationshipDescription?, _ obj: NSManagedObject) {
        guard let relationship = relationship else { return }
        
        if relationship.isToMany == false {
            _setValue(nil, forKey:relationship.name, ignoreInverses: true)
        }
        else {
            _removeObject(obj, forKey: relationship.name, ignoreInverses: true, refresh: false)
        }
    }

    
    func deleteByCascade(fromRelationship relationship: NSRelationshipDescription) {

        if relationship.isToMany == false {
            guard let obj = value(forKey: relationship.name) as? NSManagedObject else { return }
            if obj.isDeleted == false { managedObjectContext?.delete(obj) }
        }
        else {
            let objects = value(forKey: relationship.name) as! Set<NSManagedObject>
            for obj in objects {
                if obj.isDeleted == false { managedObjectContext?.delete(obj) }
                _removeObject(obj, forKey: relationship.name, refresh: false)
            }
//            managedObjectContext?.refresh(self, mergeChanges: false)
        }
    }
    
    open override var description: String {
        get {
            var str = ""
            str += "<\(entity.name!): \(Unmanaged.passUnretained(self).toOpaque())>\n"
            let keys = entity.attributesByName.keys.sorted()
            for k in keys {
                let v = value(forKey: k)
                if v == nil { str += "  \(k): <null>\n" }
                else if v is NSNull { str += "  \(k): <null>\n" }
                else if v is String { str += "  \(k): '\(v!)'\n" }
                else { str += "  \(k): \(v!)\n" }
            }
            
            return str
        }
    }

}

