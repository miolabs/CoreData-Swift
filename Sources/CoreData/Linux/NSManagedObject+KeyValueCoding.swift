//
//  File.swift
//  
//
//  Created by Javier Segura Perez on 10/11/2020.
//

import Foundation

#if os(Linux)

extension NSManagedObject
{
    open func value(forKeyPath keyPath: String) -> Any? {
        
        let keys = keyPath.split(separator: ".")
        let key = String(keys[0])
        let value = self.value(forKey: key)
        if keys.count == 1 { return value }
        
        if value == nil { return nil }
        
        guard let rel = entity.relationshipsByName[key] else { return nil }
        if rel.isToMany { return nil }
        
        let obj = value as! NSManagedObject
        
        let new_keypath = keys[1...].joined(separator: ".")
        return obj.value(forKeyPath: new_keypath)
    }
    
//    open func setValue(_ value: Any?, forKey key: String) { }
}

#endif

