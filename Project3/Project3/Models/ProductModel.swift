//
//  ProductModel.swift
//  Project3
//
//  Created by Alumno on 30/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class ProductModel {
    let name: String
    let description: String
    let price: Float
    let IDProduct: Int
    
    init(name: String, description: String, pid: Int, price: Float) {
        self.name = name
        self.description = description
        self.IDProduct = pid
        self.price = price
}
}
