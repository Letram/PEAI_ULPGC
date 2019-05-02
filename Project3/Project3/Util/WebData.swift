//
//  WebData.swift
//  Project2
//
//  Created by Alumno on 24/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class WebData {
    static let SERVER_URL = URL(string: "http://appstip.iatext.ulpgc.es/ventas/server.php?")
    
    static let CUSTOMER_GETALL = "QueryCustomers"
    static let CUSTOMER_INSERT = "InsertCustomer"
    static let CUSTOMER_UPDATE = "UpdateCustomer"
    static let CUSTOMER_DELETE = "DeleteCustomer"
    
    static let PRODUCT_GETALL = "QueryProducts"
    static let PRODUCT_INSERT = "InsertProduct"
    static let PRODUCT_UPDATE = "UpdateProduct"
    static let PRODUCT_DELETE = "DeleteProduct"
    
    static let ORDER_GETALL = "QueryOrders"
    static let ORDER_INSERT = "InsertOrder"
    static let ORDER_UPDATE = "UpdateOrder"
    static let ORDER_DELETE = "DeleteOrder"
}
