//
//  CarInfoViewModel.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import Foundation
import Alamofire

final class CarInfoViewModel {
    func makeRequest(vin: String, completionHandler: @escaping (Car?, Error?) -> Void) {
        Alamofire.request(Convertible.getCarInfo(vin: vin), method: .get)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    completionHandler(nil, error)
                case .success:
                    if let data = try? JSONDecoder().decode(Car.self, from: response.data!) {
                        completionHandler(data, nil)
                    }
                }
            }
    }
}
