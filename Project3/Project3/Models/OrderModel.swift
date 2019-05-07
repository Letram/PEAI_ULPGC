import Foundation

class OrderModel: DBModel {
    
    var customer: CustomerModel
    var product: ProductModel
    var date: Date
    var code: String
    var quantity: Int
    var IDOrder: Int
    
    init(customer: CustomerModel, product: ProductModel, date: Date, code: String, quantity: Int, idOrder: Int) {
        self.customer = customer
        self.product = product
        self.date = date
        self.code = code
        self.quantity = quantity
        self.IDOrder = idOrder
    }
}
