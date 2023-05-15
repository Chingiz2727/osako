//
//  CarInfoViewController.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import UIKit
import UGOUIKit
class CarInfoViewController: UIViewController, ViewHolder {
    typealias RootViewType = CarInfoView
    
    private let viewModel: CarInfoViewModel
    private let vin: String
    private let dataSource = CarInfoTableDataSource()
    
    init(viewModel: CarInfoViewModel = CarInfoViewModel(), vin: String) {
        self.viewModel = viewModel
        self.vin = vin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = CarInfoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        rootView.tableView.dataSource = dataSource

        viewModel.makeRequest(vin: vin) { [weak self] car, error in
            guard let car else { return }
            let rowData = CarMapper.map(data: car.data)
            self?.dataSource.rowData = rowData
            self?.rootView.tableView.reloadData()
        }
    }
}
