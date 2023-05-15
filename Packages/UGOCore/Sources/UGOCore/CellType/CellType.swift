//
//  Registerable.swift
//  picker-ios
//
//  Created by Nikita Koltsov on 7/29/19.
//  Copyright © 2019 Picker. All rights reserved.
//

import UIKit

public protocol CellType: NSObjectProtocol {
  
}

extension CellType where Self: UITableViewCell {
  fileprivate static var identifier: String {
    return String(describing: self)
  }
  
  fileprivate static var xibName: String? { //Treat identifier as xib name by default
    return identifier
  }
  
  static func dequeue(from tableView: UITableView, indexPath: IndexPath) -> Self {
    return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Self
  }
}

extension CellType where Self: UICollectionViewCell {
  fileprivate static var identifier: String {
    return String(describing: self)
  }
  
  fileprivate static var xibName: String? { //Treat identifier as xib name by default
    return identifier
  }
  
  static func dequeue(from collectionView: UICollectionView, indexPath: IndexPath) -> Self {
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Self
  }
}

// MARK: - NibRegisterable

public protocol NibRegisterableCell: CellType {
}

extension NibRegisterableCell where Self: UITableViewCell {
  public static func register(in tableView: UITableView) {
    tableView.register(UINib(nibName: xibName ?? identifier, bundle: nil), forCellReuseIdentifier: identifier)
  }
}

extension NibRegisterableCell where Self: UICollectionViewCell {
  public static func register(in collectionView: UICollectionView) {
    collectionView.register(UINib(nibName: xibName ?? identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
  }
}

// MARK: - Registerable

public protocol RegisterableCell: CellType {
}

extension RegisterableCell where Self: UITableViewCell {
  public static func register(in tableView: UITableView) {
    tableView.register(self, forCellReuseIdentifier: identifier)
  }
}

extension RegisterableCell where Self: UICollectionViewCell {
  public static func register(in collectionView: UICollectionView) {
    collectionView.register(self, forCellWithReuseIdentifier: identifier)
  }
}
