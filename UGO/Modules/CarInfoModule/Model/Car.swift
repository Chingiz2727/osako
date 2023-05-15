//
//  Car.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import Foundation

struct Car: Codable {
    let code: Int
    let value: String
    let count: Int
    let data: [CarData]
}

struct CarData: Codable {
    let id, date, vin, gn: String
    let mark, model, sts, pts: String
    let fio, birthday, phone, cost: String
    let file: String
}

struct RowData {
    let title: String
    let value: String
}

enum CarMapper {
    static func map(data: [CarData]) -> [RowData] {
        guard let info = data.first else { return [] }
        let row: [RowData] = [
            .init(title: "Дата", value: info.date),
            .init(title: "VIN", value: info.vin),
            .init(title: "Гос Номер", value: info.gn),
            .init(title: "Марка", value: info.mark),
            .init(title: "Модель", value: info.model),
            .init(title: "СТС", value: info.sts),
            .init(title: "ПТС", value: info.pts),
            .init(title: "ФИО", value: info.fio),
            .init(title: "Дата рождения", value: info.birthday),
            .init(title: "Телефон", value: info.phone),
            .init(title: "Цена", value: info.cost)
        ]
        return row
    }
}
