//
//  QueryService.swift
//  Project2
//
//  Created by Alumno on 24/04/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import Foundation

protocol QueryServiceInterface{
    typealias queryResult = ([DBModel], String) -> ()
    typealias insertResult = ([DBModel], String) -> ()
    typealias updateResult = ([DBModel], String) -> ()
    typealias deleteResult = ([DBModel], String) -> ()
    typealias JsonDict = [String: Any]
    
    func getAll(completion: @escaping queryResult)
    func insert(params: JsonDict, completion: @escaping insertResult)
    func update(params: JsonDict, completion: @escaping updateResult)
    func delete(params: JsonDict, completion: @escaping deleteResult)
}
