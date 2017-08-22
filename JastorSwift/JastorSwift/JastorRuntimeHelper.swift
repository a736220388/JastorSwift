//
//  JastorRuntimeHelper.swift
//  JastorSwift
//
//  Created by kangtaier on 2017/8/14.
//  Copyright © 2017年 kangtaier. All rights reserved.
//

import UIKit

class JastorRuntimeHelper: NSObject {
    static var propertyListByClass:NSMutableDictionary?
    static var propertyClassByClassAndPropertyName:NSMutableDictionary?
    
    class func property_getTypeName(property:objc_property_t){
        let attributes = property_getAttributes(property)
        var buffer:UnsafeMutablePointer<Int8>?
        strcpy(buffer, attributes)
        var state:UnsafeMutablePointer<Int8>? = buffer
        while let attribute = strsep(&state, ","){
            if NSString.init(utf8String: &attribute[0]) == "T" {
                let len = strlen(attribute) - 1
                var char = NSString.init(utf8String: &attribute[Int(len)])
                char = "\0"
                return
            }
        }
        
    }
    
    class func isPropertyReadOnly(klass:AnyClass,propertyName:NSString)->Bool{
        let type:UnsafePointer<Int8> = property_getAttributes(class_getProperty(klass, propertyName.utf8String))
        let typeString = NSString.init(utf8String: type)
        let attributes = typeString?.components(separatedBy: ",")
        let typeAttribute = attributes?[1]
        return (typeAttribute?.contains("R"))!
    }

    class func propertyNames(klass:AnyClass)->NSArray{
        if klass == Jastor.self {
            return NSArray()
        }
        if (propertyListByClass == nil) {
            propertyListByClass = NSMutableDictionary()
        }
        
        let className:NSString = NSStringFromClass(klass) as NSString
        let value = propertyListByClass?.object(forKey: className)
        if (value != nil) {
            return value as! NSArray
        }
        
        let propertyNamesArray = NSMutableArray()
        var propertyCount:UInt32 = 0
        let properties = class_copyPropertyList(klass, &propertyCount)
        for i in 0..<propertyCount {
            let property:objc_property_t = (properties?[Int(i)])!
            let name = property_getName(property)
            propertyNamesArray.add(NSString.init(utf8String: name!)!)
        }
        free(properties)
        
        propertyListByClass?.setObject(propertyNamesArray, forKey: className)
        let arr = JastorRuntimeHelper.propertyNames(klass: class_getSuperclass(klass))
        propertyNamesArray.addObjects(from: arr as! [Any])
        return propertyNamesArray
    }
    
    class func propertyClassForPropertyName(propertyName:NSString,klass:AnyClass)->AnyClass{
        if (propertyClassByClassAndPropertyName == nil) {
            propertyClassByClassAndPropertyName = NSMutableDictionary()
        }
        
        let key = NSString.init(format: "%@:%@", NSStringFromClass(klass),propertyName)
        let value = propertyClassByClassAndPropertyName?.object(forKey: key)
        if (value != nil) {
            return NSClassFromString(value as! String)!
        }
        
        var propertyCount:UInt32 = 0
        let properties = class_copyPropertyList(klass, &propertyCount)
        let cPropertyName = propertyName.utf8String
        for i in 0..<propertyCount {
            let property = properties?[Int(i)]
            let name = property_getName(property)
            if strcmp(cPropertyName, name) == 0 {
                free(properties)
                let className = NSString.init(utf8String: )
            }
        }
    }
}






