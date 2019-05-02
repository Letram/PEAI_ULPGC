//
//  OrderQueryService.swift
//  Project3
//
//  Created by Alumno on 02/05/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class OrderQueryService: QueryServiceInterface {
    
    let defaultSession = URLSession(configuration: .default)
    
    var delegate: OrderListViewController? = nil
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var orders: [OrderModel] = []
    var insertedId: Int? = nil
    var updateResultReq: Bool? = false
    var deleteResultReq: Bool? = false
    
    func getAll(completion: @escaping queryResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.ORDER_GETALL))!)
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
                    completion(self.orders, self.errorMessage)
                }
            }
        })
        // Se lanza la tarea
        dataTask?.resume()
    }
    
    func updateResults(_ data: Data){
        var response: JsonDict?
        orders.removeAll()
        
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
        for orderObj in orderArray {
            if let orderAux = orderObj as? JsonDict{
                
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd"
                
                let previewCustomerName = orderAux["customerName"] as? String
                let previewProductName = orderAux["productName"] as? String
                let previewOid = orderAux["IDProduct"] as? String
                let previewPid = orderAux["price"] as? String
                let previewUid = orderAux["IDCustomer"] as? String
                let previewCode = orderAux["code"] as? String
                let previewQty = orderAux["quantity"] as? String
                let previewPrice = orderAux["price"] as? String
                let previewDate = orderAux["date"] as? String
                orders.append(OrderModel(
                    IDCustomer: Int(previewUid!)!,
                    IDProduct: Int(previewPid!)!,
                    IDOrder: Int(previewOid!)!,
                    customerName: previewCustomerName!,
                    productName: previewProductName!,
                    code: previewCode!,
                    quantity: Int(previewQty!)!,
                    date: dateFormat.date(from: previewDate!)!,
                    price: Float(previewPrice!)!)
                )
            }
                
            else {
                errorMessage += "Problem parsing customerAux\n"
            }
        }
    }
    
    func insert(params: JsonDict, completion: @escaping insertResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_INSERT))!)
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
                    self.insertProductResponse(data)
                    DispatchQueue.main.async {
                        completion(self.insertedId!, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func insertProductResponse(_ data: Data){
        var response: JsonDict?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        }catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        let fault = response!["fault"] as? Int
        if fault == 1{
            errorMessage += "Insert problem!"
            return
        }
        guard let insertedIdFromResponse = response!["data"] as? Int else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        insertedId = insertedIdFromResponse
    }
    
    func update(params: JsonDict, completion: @escaping updateResult) {
        dataTask?.cancel()
        
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_UPDATE))!)
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
                    self.updateProductResponse(data)
                    DispatchQueue.main.async {
                        completion(self.updateResultReq!, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func updateProductResponse(_ data: Data){
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
        var req = URLRequest(url: URL(string: ((WebData.SERVER_URL?.absoluteString)! + WebData.PRODUCT_DELETE))!)
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
                    self.deleteProductResponse(data)
                    DispatchQueue.main.async {
                        completion(self.deleteResultReq!, self.errorMessage)
                    }
                }
            })
            // Se lanza la tarea
            dataTask?.resume()
            
        } catch {
            print("Error")
        }
    }
    
    func deleteProductResponse(_ data: Data){
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