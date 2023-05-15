//
//  BroadcastService.swift
//  NKoltsov-utils
//  This implementation is an amended version of https://github.com/100mango/SwiftNotificationCenter
//
//  Created by Nikita Koltsov on 8/3/19.
//  Copyright © 2019 Nikita Koltsov. All rights reserved.
//

import Foundation

struct WeakObject<T: AnyObject>: Equatable, Hashable {
  private let identifier: ObjectIdentifier
  weak var object: T?
  
  init(_ object: T) {
    self.object = object
    self.identifier = ObjectIdentifier(object)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (left: WeakObject<T>, right: WeakObject<T>) -> Bool {
    return left.identifier == right.identifier
  }
}

struct WeakSet<T: AnyObject>: Sequence {
  var objects: Set<WeakObject<T>>
  
  init() {
    self.objects = Set<WeakObject<T>>([])
  }
  
  init(_ object: T) {
    self.objects = Set<WeakObject<T>>([WeakObject(object)])
  }
  
  init(_ objects: [T]) {
    self.objects = Set<WeakObject<T>>(objects.map { WeakObject($0) })
  }
  
  var allObjects: [T] {
    return objects.compactMap { $0.object }
  }
  
  func contains(_ object: T) -> Bool {
    return self.objects.contains(WeakObject(object))
  }
  
  mutating func add(_ object: T) {
    //prevent ObjectIdentifier be reused
    if self.contains(object) {
      self.remove(object)
    }
    self.objects.insert(WeakObject(object))
  }
  
  mutating func add(_ objects: [T]) {
    objects.forEach { self.add($0) }
  }
  
  mutating func remove(_ object: T) {
    self.objects.remove(WeakObject<T>(object))
  }
  
  mutating func remove(_ objects: [T]) {
    objects.forEach { self.remove($0) }
  }
  
  mutating func removeAll() {
    objects.removeAll()
  }
  
  func makeIterator() -> AnyIterator<T> {
    let objects = self.allObjects
    var index = 0
    return Iterator({ () -> T? in
      defer { index += 1 }
      return index < objects.count ? objects[index] : nil
    })
  }
}

/// Convenience class as alternate to NotificationCenter
class BroadcastService {
  private static var observersDict: [String: Any] = [:]
  private static let notificationsQueue = DispatchQueue(label: "com.ios.broadcast.queue", qos: .background, attributes: .concurrent)
  
  static func register<T>(_ type: T.Type, observer: T) {
    let key = "\(type)"
    addObserver(observer as AnyObject, key: key)
  }
  
  static func unregister<T>(_ type: T.Type, observer: T) {
    let key = "\(type)"
    removeObserver(observer as AnyObject, key: key)
  }
  
  static func unregister(_ observer: AnyObject) {
    removeObserver(observer)
  }
  
  static func notify<T>(_ protocolType: T.Type, block: (T) -> Void) {
    let key = "\(protocolType)"
    guard let set = getSet(key) else { return }
    
    for item in set {
      if let observer = item as? T {
        block(observer)
      }
    }
  }
}

private extension BroadcastService {
  static func addObserver<T: AnyObject>(_ observer: T, key: String) {
    notificationsQueue.async(flags: .barrier) {
      if var set = self.observersDict[key] as? WeakSet<T> {
        set.add(observer)
        self.observersDict[key] = set
      } else {
        self.observersDict[key] = WeakSet<T>(observer)
      }
    }
  }
  
  static func removeObserver<T: AnyObject>(_ observer: T, key: String) {
    notificationsQueue.async(flags: .barrier) { [weak observer] in
      if var set = self.observersDict[key] as? WeakSet<T>, let observer = observer {
        set.remove(observer)
        self.observersDict[key] = set
      }
    }
  }
  
  static func removeObserver(_ observer: AnyObject) {
    notificationsQueue.async(flags: .barrier) {
      let dict = self.observersDict
      var result: [String: Any] = [:]
      
      for (key, value) in dict {
        if var set = value as? WeakSet<AnyObject> {
          set.remove(observer)
          result[key] = set
        }
      }
      
      self.observersDict = result
    }
  }
  
  static func getSet(_ key: String) -> WeakSet<AnyObject>? {
    var result: WeakSet<AnyObject>?
    notificationsQueue.sync {
      result = self.observersDict[key] as? WeakSet<AnyObject>
    }
    
    return result
  }
}
