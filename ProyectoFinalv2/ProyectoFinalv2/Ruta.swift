//
//  Ruta.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 18/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import Foundation
import UIKit

class Ruta {
    
    var titulo: String = ""
    var descripcion: String = ""
    var image: UIImage?
    var puntosEnLaRuta = [Punto]()
    
    init () {}
    
    init (titulo : String, descripcion : String) {
        self.titulo = titulo
        self.descripcion = descripcion
    }
    
    func agregarElemento(punto: Punto)
    {
        self.puntosEnLaRuta.append(punto)
    }
    
    func obtenerIndicePorTitulo(titulo : String?) -> Int?
    {
        var indiceTitulo : Int = 0
        if (titulo == nil) {
            return nil
        }
        
        var index = 0;
        for punto in self.puntosEnLaRuta {
            if punto.titulo == titulo {
                indiceTitulo = index
                break
            }
            index += 1;
        }
        
        return indiceTitulo
    }
    
}