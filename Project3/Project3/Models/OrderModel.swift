//
//  OrderModell.swift
//  Project3
//
//  Created by Alumno on 30/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class OrderModel: DBModel {
    let IDCustomer: Int
    let IDProduct: Int
    let IDOrder: Int
    let customerName: String
    let productName: String
    let code: String
    let quantity: Int
    let price: Float
    let date: Date
    
    init(IDCustomer: Int, IDProduct: Int, IDOrder: Int, customerName: String, productName: String, code: String, quantity: Int, date: Date, price: Float) {
        self.IDCustomer = IDCustomer
        self.IDProduct = IDProduct
        self.IDOrder = IDOrder
        self.customerName = customerName
        self.productName = productName
        self.code = code
        self.quantity = quantity
        self.price = price
        self.date = date
    }
}
