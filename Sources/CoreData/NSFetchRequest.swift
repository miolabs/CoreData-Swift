//
//  MIOFetchRequest.swift
//  
//
//  Created by Javier Segura Perez on 22/05/2019.
//

import Foundation

public struct NSFetchRequestResultType : OptionSet
{
    public let rawValue:UInt
    public init(rawValue:UInt){
        self.rawValue = rawValue
    }
    
    public static var managedObjectResultType:NSFetchRequestResultType { get { return NSFetchRequestResultType(rawValue: 1 << 0) } }
    public static var managedObjectIDResultType:NSFetchRequestResultType { get { return NSFetchRequestResultType(rawValue: 1 << 1) } }
    public static var dictionaryResultType:NSFetchRequestResultType { get { return NSFetchRequestResultType(rawValue: 1 << 2) } }
    public static var countResultType:NSFetchRequestResultType{ get { return NSFetchRequestResultType(rawValue: 1 << 3) } }
}

public protocol NSFetchRequestResult : NSObjectProtocol {}

extension NSNumber : NSFetchRequestResult {}
extension NSDictionary : NSFetchRequestResult {}
extension NSManagedObject : NSFetchRequestResult {}
extension NSManagedObjectID : NSFetchRequestResult {}

open class NSFetchRequest<ResultType> : NSPersistentStoreRequest where ResultType : NSFetchRequestResult
{
    public convenience init(entityName:String) {
        self.init()
        _entityName = entityName
    }
 
    open func execute() throws -> [ResultType] {
        return []
    }
    
    open var entity: NSEntityDescription?
    
    var _entityName:String?
    open var entityName: String? { get { return _entityName } }
    
    open var predicate: NSPredicate?
    
    open var sortDescriptors: [NSSortDescriptor]?
    
    open var fetchLimit: Int = 0
    
    //open var affectedStores: [NSPersistentStore]?

    
    /* Returns/sets the result type of the fetch request (the instance type of objects returned from executing the request.)  Setting the value to NSManagedObjectIDResultType will demote any sort orderings to "best effort" hints if property values are not included in the request.  Defaults to NSManagedObjectResultType.
    */
    
    open var resultType: NSFetchRequestResultType = NSFetchRequestResultType.managedObjectResultType

    
    /* Returns/sets if the fetch request includes subentities.  If set to NO, the request will fetch objects of exactly the entity type of the request;  if set to YES, the request will include all subentities of the entity for the request.  Defaults to YES.
    */
    open var includesSubentities = true

    
    /* Returns/sets if, when the fetch is executed, property data is obtained from the persistent store.  If the value is set to NO, the request will not obtain property information, but only information to identify each object (used to create NSManagedObjectIDs.)  If managed objects for these IDs are later faulted (as a result attempting to access property values), they will incur subsequent access to the persistent store to obtain their property values.  Defaults to YES.
    */
    open var includesPropertyValues = true

    
    /* Returns/sets if the objects resulting from a fetch request are faults.  If the value is set to NO, the returned objects are pre-populated with their property values (making them fully-faulted objects, which will immediately return NO if sent the -isFault message.)  If the value is set to YES, the returned objects are not pre-populated (and will receive a -didFireFault message when the properties are accessed the first time.)  This setting is not utilized if the result type of the request is NSManagedObjectIDResultType, as object IDs do not have property values.  Defaults to YES.
    */
    open var returnsObjectsAsFaults = true

    
    /* Returns/sets an array of relationship keypaths to prefetch along with the entity for the request.  The array contains keypath strings in NSKeyValueCoding notation, as you would normally use with valueForKeyPath.  (Prefetching allows Core Data to obtain developer-specified related objects in a single fetch (per entity), rather than incurring subsequent access to the store for each individual record as their faults are tripped.)  Defaults to an empty array (no prefetching.)
    */
    open var relationshipKeyPathsForPrefetching: [String]?

    
    /* Results accommodate the currently unsaved changes in the NSManagedObjectContext.  When disabled, the fetch request skips checking unsaved changes and only returns objects that matched the predicate in the persistent store.  Defaults to YES.
    */
    open var includesPendingChanges = true

    
    /* Returns/sets if the fetch request returns only distinct values for the fields specified by propertiesToFetch. This value is only used for NSDictionaryResultType. Defaults to NO. */
    open var returnsDistinctResults = false

    
    /* Specifies a collection of either NSPropertyDescriptions or NSString property names that should be fetched. The collection may represent attributes, to-one relationships, or NSExpressionDescription.  If NSDictionaryResultType is set, the results of the fetch will be dictionaries containing key/value pairs where the key is the name of the specified property description.  If NSManagedObjectResultType is set, then NSExpressionDescription cannot be used, and the results are managed object faults partially pre-populated with the named properties */
    open var propertiesToFetch: [Any]?

    
    /* Allows you to specify an offset at which rows will begin being returned.  Effectively, the request will skip over 'offset' number of matching entries.  For example, given a fetch which would normally return a, b, c, and d, specifying an offset of 1 will return b, c, and d and an offset of 4  will return an empty array. Offsets are ignored in nested requests such as subqueries.  Default value is 0.  */
    open var fetchOffset:Int = 0

    
    /* This breaks the result set into batches.  The entire request will be evaluated, and the identities of all matching objects will be recorded, but no more than batchSize objects' data will be fetched from the persistent store at a time.  The array returned from executing the request will be a subclass that transparently faults batches on demand.  For purposes of thread safety, the returned array proxy is owned by the NSManagedObjectContext the request is executed against, and should be treated as if it were a managed object registered with that context.  A batch size of 0 is treated as infinite, which disables the batch faulting behavior.  The default is 0. */
    
    open var fetchBatchSize: Int = 0

        
    open var shouldRefreshRefetchedObjects: Bool = false

    
    /* Specifies the way in which data should be grouped before a select statement is run in an SQL database.
     Values passed to propertiesToGroupBy must be NSPropertyDescriptions, NSExpressionDescriptions, or keypath strings; keypaths can not contain
     any to-many steps.
     If GROUP BY is used, then you must set the resultsType to NSDictionaryResultsType, and the SELECT values must be literals, aggregates,
     or columns specified in the GROUP BY. Aggregates will operate on the groups specified in the GROUP BY rather than the whole table. */
    
    open var propertiesToGroupBy: [Any]?

    
    /* Specifies a predicate that will be used to filter rows being returned by a query containing a GROUP BY. If a having predicate is
     supplied, it will be run after the GROUP BY.  Specifying a HAVING predicate requires that a GROUP BY also be specified. */
    
    open var havingPredicate: NSPredicate?
}
