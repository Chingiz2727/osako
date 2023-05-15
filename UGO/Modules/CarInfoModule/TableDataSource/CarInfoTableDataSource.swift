//
//  CarInfoTableDataSource.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import Foundation
import UIKit

enum TableConstants {
    static let cellId = "cellId"
}

final class CarInfoTableDataSource: NSObject {
    var rowData: [RowData] = []
}

extension CarInfoTableDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: TableConstants.cellId)
        let row = rowData[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.value
        return cell
    }
}
