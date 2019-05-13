import Foundation

protocol QueryServiceInterface{
    typealias queryResult = ([DBModel], String) -> ()
    typealias insertResult = ([DBModel], String) -> ()
    typealias updateResult = ([DBModel], String) -> ()
    typealias deleteResult = ([DBModel], String) -> ()
    typealias JsonDict = [String: Any]
    
    
    /*
     -Parameter completion: método que se ejecutará una vez se haya completado la operación
     */
    func getAll(completion: @escaping queryResult)
    
    /*
     -Parameter params: json con la información formateada que enviaremos al servidor
     -Parameter completion: método que se ejecutará una vez se haya completado la operación
     */
    func insert(params: JsonDict, completion: @escaping insertResult)
    func update(params: JsonDict, completion: @escaping updateResult)
    func delete(params: JsonDict, completion: @escaping deleteResult)
}
