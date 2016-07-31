//
//  InterfaceController.swift
//  ProyectoFinalv2AW Extension
//
//  Created by Fernando Renteria Correa on 31/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import MapKit
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var mapa: WKInterfaceMap!
    
    var session : WCSession!
    override init() {
        super.init()
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]){
        self.mapa.removeAllAnnotations()
        for (latitud, longitud) in applicationContext {
            let lat: Double = Double(latitud)!
            let longStr: String = longitud as! String
            let long: Double = Double(longStr)!
            let mapLocation = CLLocationCoordinate2DMake(lat, long)
            self.mapa.addAnnotation(mapLocation, withPinColor: WKInterfaceMapPinColor.Red)
            let location = CLLocationCoordinate2D(latitude: lat,longitude: long)
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapa.setRegion(region)
            
        }
    }

}
