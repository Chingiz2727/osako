//
//  File.swift
//  
//
//  Created by Shyngys Kuandyk on 08.04.2022.
//

import Foundation

extension Bundle {
    static var current: Bundle {
        return Bundle.module
    }
}

private class _BundleClass {}
