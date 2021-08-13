//
//  ViewController.swift
//  NewTest
//
//  Created by Edison Saez Echeverria on 13-08-21.
//

import UIKit
import Alamofire
import RealmSwift

class Productos: Object {
    @Persisted var nombreProducto = ""
    @Persisted var foto = ""
    @Persisted var codigoBarra = ""
}

class ViewController: UIViewController {

    @IBOutlet weak var fistField: UITextField!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var textLoading: UITextField!
    let url:URL = URL(string: "https://www.jvstock.cl/getProductos")!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJsonDataFromService()
    
        fistField.becomeFirstResponder()
        fistField.isHidden = true
        fistField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let txt = textField.text!
        if txt.count > 12 {
            textField.text = ""
            print("data: ", txt)
            let val:Productos = queryFromDB(code: txt) as! Productos
            print(val.nombreProducto)
        }
        
    }
    
    struct Json: Encodable {
        let idEmpresa: String
        let idLocal: String
    }
    
    func queryFromDB(code:String) -> Object {
        
        let productos = realm.objects(Productos.self)
        let producto = productos.filter("codigoBarra == '\(code)'").first!
        
        
        return producto
        
    }

    func getJsonDataFromService(){
        let json = Json (idEmpresa: "1", idLocal: "3135")
        
        AF.request(url, method: .post, parameters: json, encoder: JSONParameterEncoder.default).responseJSON { response in
            
            print("Response JSON: \(response.value)")
            
            
            for anItem in response.value as! [Dictionary<String, AnyObject>] { // or [[String:AnyObject]]
              let codigoBarra = anItem["codigoBarra"] as! String
              let foto = anItem["foto"] as! String
              let nombreProducto = anItem["nombreProducto"] as! String
                
                print(codigoBarra)
                
                try! self.realm.write {
                
                let producto = Productos()
                producto.foto = foto
                producto.codigoBarra = codigoBarra
                producto.nombreProducto = nombreProducto
                
                    self.realm.add(producto)
                    
                }
                
            }
            
            self.progress.alpha = 0.0
            self.progress.setNeedsLayout()
            self.textLoading.alpha = 0.0
            self.textLoading.setNeedsLayout()

        }
        
    
    }

}

