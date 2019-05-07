import Foundation

class CustomerOrders: DBModel{
    let customerName: String
    let idCustomer: Int
    var customerOrders: [OrderModel]
    
    init(customerName: String, idCustomer: Int, customerOrders: [OrderModel]) {
        self.customerName = customerName
        self.idCustomer = idCustomer
        self.customerOrders = customerOrders
    }
}
