import Foundation

class CustomerQueryService : QueryServiceInterface{
    let defaultSession = URLSession(configuration: .default)
    
    var delegate: CustomerListViewController? = nil
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    
    var customers: [CustomerModel] = []{
        didSet{
            customers = customers.sorted(by: {$0.name < $1.name})
            CustomerQueryService.staticCustomers = customers
        }
    }
    
    static var staticCustomers: [CustomerModel] = []
    
    var insertedId: Int? = nil
    var updateResultReq: Bool? = false
    var deleteResultReq: Bool? = false
    
    func getAll(completion: @escaping queryResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.CUSTOMER_GETALL))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "GET"
        
        // Shared session es para peticiones básicas que no necesitan configuración
        let session = URLSession.shared
        
        // Tarea asíncrona para recuperar el contenido de una url.
        dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
            }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self.updateResults(data)
                DispatchQueue.main.async {
                    completion(self.customers as [CustomerModel], self.errorMessage)
                }
            }
        })
        // Se lanza la tarea
        dataTask?.resume()
    }
    
    func updateResults(_ data: Data){
        var response: JsonDict?
        customers.removeAll()
        
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
        guard let customerArray = response!["data"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        for customerObj in customerArray {
            if let customerAux = customerObj as? JsonDict{
                let previewName = customerAux["name"] as? String
                let previewAddress = customerAux["address"] as? String
                let previewUid = customerAux["IDCustomer"] as? String
                customers.append(CustomerModel(name: previewName!, address: previewAddress!, uid: Int(previewUid!)!))
            }
            else {
                errorMessage += "Problem parsing customerAux\n"
            }
        }
    }
    
    func insert(params: JsonDict, completion: @escaping insertResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.CUSTOMER_INSERT))!)
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
                    self.insertCustomerResponse(data)
                    if(self.insertedId != -1){
                        let customerAux = CustomerModel(name: params["name"] as! String, address: params["address"] as! String, uid: self.insertedId!)
                        self.customers.append(customerAux)
                    }
                    DispatchQueue.main.async {
                        completion(self.customers as [CustomerModel], self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()

        } catch {
            print("Error")
        }
    }
    
    func insertCustomerResponse(_ data: Data){
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
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.CUSTOMER_UPDATE))!)
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
                    self.updateCustomerResponse(data)
                    if self.updateResultReq! {
                        let customerAux = CustomerModel(name: params["name"] as! String, address: params["address"] as! String, uid: params["IDCustomer"] as! Int )
                        self.customers[self.customers.firstIndex(where: {$0.IDCustomer == params["IDCustomer"] as! Int})!] = customerAux
                    }
                    DispatchQueue.main.async {
                        completion(self.customers, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func updateCustomerResponse(_ data: Data){
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
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.CUSTOMER_DELETE))!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "DELETE"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            req.httpBody = jsonData
            print(jsonData.base64EncodedString())
            // Shared session es para peticiones básicas que no necesitan configuración
            let session = URLSession.shared
            
            // Tarea asíncrona para recuperar el contenido de una url.
            dataTask = session.dataTask(with: req, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    self.errorMessage += "Datatask error: " + (error.localizedDescription) + "\n"
                }else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.deleteCustomerResponse(data)
                    if self.deleteResultReq! {
                        self.customers = self.customers.filter({$0.IDCustomer != params["IDCustomer"] as! Int})
                    }
                    DispatchQueue.main.async {
                        completion(self.customers, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func deleteCustomerResponse(_ data: Data){
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
