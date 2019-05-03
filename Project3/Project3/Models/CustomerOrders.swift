//
//  CustomerOrders.swift
//  Project3
//
//  Created by Alumno on 03/05/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class CustomerOrders: DBModel{
    let customerName: String
    var customerOrders: [OrderModel]
    
    init(customerName: String, customerOrders: [OrderModel]) {
        self.customerName = customerName
        self.customerOrders = customerOrders
    }
}
