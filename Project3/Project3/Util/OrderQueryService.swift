import Foundation

class OrderQueryService: QueryServiceInterface {
    
    let defaultSession = URLSession(configuration: .default)
    
    var delegate: OrderListViewController? = nil
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var customerOrders: [CustomerOrders] = []
    var insertedId: Int? = nil
    var updateResultReq: Bool? = false
    var deleteResultReq: Bool? = false
    
    let customerService = CustomerQueryService()
    let productService = ProductQueryService()
    
    var customers = CustomerQueryService.staticCustomers
    var products = ProductQueryService.staticProducts
    
    func getAll(completion: @escaping queryResult) {
        dataTask?.cancel()
        
        customerService.getAll(){_,_ in
            self.productService.getAll(){_,_ in
                var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.ORDER_GETALL))!)
                req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "GET"
                
                // Shared session es para peticiones básicas que no necesitan configuración
                let session = URLSession.shared
                
                // Tarea asíncrona para recuperar el contenido de una url.
                self.dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if let error = error {
                        self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                    }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        self.getOrdersReponse(data)
                        self.customerOrders = self.customerOrders.filter({$0.customerOrders.count > 0})
                        DispatchQueue.main.async {
                            completion(self.customerOrders, self.errorMessage)
                        }
                    }
                })
                // Se lanza la tarea
                self.dataTask?.resume()
            }
        }
    }
    
    func getOrdersReponse(_ data: Data){
        self.customers = CustomerQueryService.staticCustomers
        self.products = ProductQueryService.staticProducts
        
        var response: JsonDict?
        customerOrders.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "GetAll problem!"
            return
        }
        guard let orderArray = response!["data"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        var orders: [OrderModel] = []
        var lastCustomerName: String = ""
        var lastCustomerID: Int = -1
        for (index, orderObj) in orderArray.enumerated() {
            if let orderAux = orderObj as? JsonDict{
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd"

                let previewCustomerName: String? = orderAux["customerName"] as? String
                
                let previewOid: String? = orderAux["IDOrder"] as? String
                let previewPid: String? = orderAux["IDProduct"] as? String
                let previewUid: String? = orderAux["IDCustomer"] as? String
                let previewCode: String? = orderAux["code"] as? String
                let previewQty: String? = orderAux["quantity"] as? String
                let previewDate: String? = orderAux["date"] as? String
                
                if(valid(pid: previewPid, uid: previewUid, date: previewDate)){
                    if lastCustomerName == "" {
                        
                        lastCustomerName = previewCustomerName!
                        lastCustomerID = Int(previewUid!)!
                        
                    } else if lastCustomerName != previewCustomerName! {
                        customerOrders.append(CustomerOrders(customerName: lastCustomerName, idCustomer: lastCustomerID, customerOrders: orders))
                        print("\(lastCustomerName) has \(orders.count) orders!")
                        
                        orders = []
                        lastCustomerName = previewCustomerName!
                        lastCustomerID = Int(previewUid!)!
                    }
                    let orderCustomer = customers.filter({$0.IDCustomer == Int(previewUid!)})
                    let orderProduct = products.filter({$0.IDProduct == Int(previewPid!)})
                    orders.append(OrderModel(
                        customer: orderCustomer[0],
                        product: orderProduct[0],
                        date: dateFormat.date(from: previewDate!)!,
                        code: previewCode!,
                        quantity: Int(previewQty!)!,
                        idOrder: Int(previewOid!)!)
                    )
                    if(index == orderArray.count-1){
                        customerOrders.append(CustomerOrders(customerName: lastCustomerName, idCustomer: lastCustomerID, customerOrders: orders))
                        print("\(lastCustomerName) has \(orders.count) orders!")
                        
                        orders = []
                        lastCustomerName = previewCustomerName!
                    }
                }
            }
            else {
                errorMessage += "Problem parsing orderAux\n"
            }
        }
    }
    
    private func valid(pid: String?, uid: String?, date: String?) -> Bool{
        if let _ = pid, let _ = uid, let _ = date {
            return true
        }
        return false
    }
    
    func insert(params: JsonDict, completion: @escaping insertResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.ORDER_INSERT))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.insertOrderResponse(data)
                    if(self.insertedId != -1){
                        let dateFormat = DateFormatter()
                        dateFormat.dateFormat = "yyyy-MM-dd"
                        let idCustomer = params["IDCustomer"] as! Int
                        let idProduct = params["IDProduct"] as! Int
                        let customerAux = self.customers[self.customers.firstIndex(where: {$0.IDCustomer == idCustomer})!]
                        let productAux = self.products[self.products.firstIndex(where: {$0.IDProduct == idProduct})!]
                        let orderAux = OrderModel(
                            customer: customerAux,
                            product: productAux,
                            date: dateFormat.date(from: params["date"] as! String)!,
                            code: params["code"] as! String,
                            quantity: params["quantity"] as! Int,
                            idOrder: self.insertedId!
                        )
                        let customerOrderIndex = self.customerOrders.firstIndex(where: {$0.idCustomer == idCustomer})
                        if(customerOrderIndex != nil){
                            self.customerOrders[customerOrderIndex!].customerOrders.append(orderAux)
                        }else{
                            let newCustomerOrder = CustomerOrders(customerName: customerAux.name, idCustomer: customerAux.IDCustomer, customerOrders: [orderAux])
                            self.customerOrders.append(newCustomerOrder)
                        }
                    }
                    self.customerOrders = self.customerOrders.filter({$0.customerOrders.count > 0})
                    DispatchQueue.main.async {
                        completion(self.customerOrders, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func insertOrderResponse(_ data: Data){
        self.customers = CustomerQueryService.staticCustomers
        self.products = ProductQueryService.staticProducts
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            insertedId = -1
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Insert problem!"
            insertedId = -1
            return
        }
        guard let insertedIdFromResponse = response!["data"] as? Int else {
            errorMessage += "Dictionary does not contain results key\n"
            insertedId = -1
            return
        }
        insertedId = insertedIdFromResponse
    }
    
    func update(params: JsonDict, completion: @escaping updateResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.ORDER_UPDATE))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "PUT"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.updateOrderResponse(data)
                    if self.updateResultReq! {
                        let dateFormat = DateFormatter()
                        dateFormat.dateFormat = "yyyy-MM-dd"
                        
                        let orderAux = OrderModel(
                            customer: self.customers[self.customers.firstIndex(where: {$0.IDCustomer == params["IDCustomer"] as! Int})!],
                            product: self.products[self.products.firstIndex(where: {$0.IDProduct == params["IDProduct"] as! Int})!],
                            date: dateFormat.date(from: params["date"] as! String)!,
                            code: params["code"] as! String,
                            quantity: params["quantity"] as! Int,
                            idOrder: params["IDOrder"] as! Int
                        )
                        //Eliminar el order viejo de la lista
                        for (customerOrderObj) in self.customerOrders{
                            customerOrderObj.customerOrders = customerOrderObj.customerOrders.filter({$0.IDOrder != orderAux.IDOrder})
                        }
                        
                        //Insertar el order en la lista de orders del usuario correspondiente en el caso de que exista. En el caso de que no exista simplemente crearemos un nuevo customerOrders con el cliente en cuestión
                        if self.customerOrders.firstIndex(where: {$0.idCustomer == orderAux.customer.IDCustomer}) != nil{
                            for (customerOrderObj) in self.customerOrders{
                                var customerOrdersOfObj = customerOrderObj.customerOrders
                                if customerOrderObj.idCustomer == orderAux.customer.IDCustomer {
                                    customerOrdersOfObj.append(orderAux)
                                }
                                customerOrderObj.customerOrders = customerOrdersOfObj
                            }
                        } else {
                            let customerOrderAux = CustomerOrders(customerName: orderAux.customer.name, idCustomer: orderAux.customer.IDCustomer, customerOrders: [orderAux])
                            self.customerOrders.append(customerOrderAux)
                        }
                        /*
                        for (customerOrderObj) in self.customerOrders{
                            var customerOrdersOfObj = customerOrderObj.customerOrders
                            if let orderIndex = customerOrdersOfObj.firstIndex(where: {$0.IDOrder == orderAux.IDOrder}){
                                customerOrdersOfObj[orderIndex] = orderAux
                            }
                            customerOrderObj.customerOrders = customerOrdersOfObj
                        }
                        */
                    }
                    self.customerOrders = self.customerOrders.filter({$0.customerOrders.count > 0})
                    DispatchQueue.main.async {
                        completion(self.customerOrders, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func updateOrderResponse(_ data: Data){
        self.customers = CustomerQueryService.staticCustomers
        self.products = ProductQueryService.staticProducts
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Update problem!"
            return
        }
        guard let updateResponse = response!["data"] as? Bool else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        updateResultReq = updateResponse
    }
    
    func delete(params: JsonDict, completion: @escaping deleteResult) {
        dataTask?.cancel()
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.ORDER_DELETE))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "DELETE"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.deleteOrderResponse(data)
                    if self.deleteResultReq! {
                        for (customerOrderObj) in self.customerOrders{
                            var customerOrdersOfObj = customerOrderObj.customerOrders
                            customerOrdersOfObj = customerOrdersOfObj.filter({$0.IDOrder != params["IDOrder"] as! Int})
                            customerOrderObj.customerOrders = customerOrdersOfObj
                        }
                    }
                    self.customerOrders = self.customerOrders.filter({$0.customerOrders.count > 0})
                    DispatchQueue.main.async {
                        completion(self.customerOrders, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func deleteOrderResponse(_ data: Data){
        self.customers = CustomerQueryService.staticCustomers
        self.products = ProductQueryService.staticProducts
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Delete problem!"
            return
        }
        guard let deleteResponse = response!["data"] as? Bool else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        deleteResultReq = deleteResponse
    }
}
