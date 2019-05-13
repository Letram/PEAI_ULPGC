//
//  File.swift
//  Project3
//
//  Created by Alumno on 09/05/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

class SOAPCustomerQueryService {
    
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
    
    func getAll(completion: @escaping ([DBModel], String) -> ()){
        let soapMsg = NSString(format: "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><QueryCustomers xmlns=\"urn://masterii.ulpgc.es/\"></QueryCustomers></soap:Body></soap:Envelope>")
        
        let url = URL(string: "http://appstip.iatext.ulpgc.es/ventas/server.php?QueryCustomers")
        var req = URLRequest(url: url!)
        
        req.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.addValue(WebData.SERVER_URN, forHTTPHeaderField: "SOAPAction")
        req.addValue(soapMsg.length.description, forHTTPHeaderField: "Content-Length")
        req.httpMethod = "GET"
        req.httpBody = soapMsg.data(using: String.Encoding.utf8.rawValue)
        
        let session = URLSession.shared
        dataTask?.cancel()
        dataTask = session.dataTask(with: req, completionHandler: {(data:Data?, response: URLResponse?, error: Error?) -> Void in
            // Esto es solo para ver en la consola cómo es la respuesta
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            //self.parser = XMLParser(data: data!)
            //self.parser?.delegate = (self as! XMLParserDelegate)
            //self.parser?.parse()
            
        })
        dataTask?.resume()
    }
    
    
    // MARK: - NSXMLParserDelegate
    
    var parser: XMLParser?
    var elementValue = ""
    
    // Comienza la lectura del documento XML
    func parserDidStartDocument(_ parser: XMLParser) {
        self.customers = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        elementValue = ""
        
        // Esto es solo para ver en la consola cómo es la respuesta
        print("elementName: " + elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementValue += string
        
        // Esto es solo para ver en la consola cómo es la respuesta
        print("elementValue: " + elementValue)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName {
            case "name": self.customers[customers.count - 1].name = elementValue
            case "address": self.customers[customers.count - 1].address = elementValue
            case "IDCustomer": self.customers[customers.count - 1].IDCustomer = Int(elementValue)!
            default: break
        }
 
    }
    
    // Finaliza la lectura del documento XML
    func parserDidEndDocument(_ parser: XMLParser) {
    }

}
/*
@IBAction func send(_ sender: UIButton) {
    number.resignFirstResponder()
    
    // Protocolo para usar SOAP
    let soapMsg = NSString(format: "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><QueryCustomers xmlns=\"urn://masterii.ulpgc.es/\"></QueryCustomers></soap:Body></soap:Envelope>")
    
    //let soapMsg = NSString(format: "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><ConvertNumberListObject xmlns=\"http://masterii.ulpgc.es/\"><number>%@</number><lang>%@</lang></ConvertNumberListObject></soap:Body></soap:Envelope>",number.text!, "es")
    
    let url = URL(string: "http://appstip.iatext.ulpgc.es/ventas/server.php?QueryCustomers")
    //let url = URL(string: "http://appstip.iatext.ulpgc.es/NumberService/NumberService.asmx?op=ConvertNumberListObject")
    
    var request = URLRequest(url: url!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.addValue("urn://ulpgc.masterii.moviles/QueryCustomers", forHTTPHeaderField: "SOAPAction")
    //request.addValue("http://masterii.ulpgc.es/ConvertNumberListObject", forHTTPHeaderField: "SOAPAction")
    request.addValue(soapMsg.length.description, forHTTPHeaderField: "Content-Length")
    request.httpMethod = "POST"
    request.httpBody = soapMsg.data(using: String.Encoding.utf8.rawValue)
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let session = URLSession.shared
    
    let task = session.dataTask(with: request, completionHandler: {
        (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        // Esto es solo para ver en la consola cómo es la respuesta
        print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        
        self.parser = XMLParser(data: data!)
        self.parser?.delegate = self
        self.parser?.parse()
        
    })
    task.resume()
    
    number.text = ""
}

// MARK: - NSXMLParserDelegate

var parser: XMLParser?
var elementValue = ""

// Comienza la lectura del documento XML
func parserDidStartDocument(_ parser: XMLParser) {
    self.result = []
}

func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    
    if elementName == "Numero" {
        result.append(NumberInfo(cardinal: "", ordinal: "", fraccionario: ""))
    }
    
    elementValue = ""
    
    // Esto es solo para ver en la consola cómo es la respuesta
    print("elementName: " + elementName)
}

func parser(_ parser: XMLParser, foundCharacters string: String) {
    elementValue += string
    
    // Esto es solo para ver en la consola cómo es la respuesta
    print("elementValue: " + elementValue)
}

func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
    switch elementName {
    case "cardinal": self.result[result.count - 1].cardinal = elementValue
    case "ordinal": self.result[result.count - 1].ordinal = elementValue
    case "fraccionario": self.result[result.count - 1].fraccionario = elementValue
    default: break
    }
}

// Finaliza la lectura del documento XML
func parserDidEndDocument(_ parser: XMLParser) {
    DispatchQueue.main.async(execute: {
        self.refreshData() // Actualiza la UI
    });
}
*/
