import Foundation

class ProductModel: DBModel {
    var name: String
    var description: String
    var price: Float
    var IDProduct: Int
    
    init(name: String, description: String, pid: Int, price: Float) {
        self.name = name
        self.description = description
        self.IDProduct = pid
        self.price = price
    }
}
