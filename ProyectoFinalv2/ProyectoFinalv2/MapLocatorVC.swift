//
//  MapLocatorVC.swift
//  ProyectoFinalv2
//
//  Created by Fernando Renteria Correa on 18/07/2016.
//  Copyright © 2016 Fernando Renteria Correa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapLocatorVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ruta: Ruta?
    var selectedAnnotationTitle: String?
    var selectedImage : UIImage?

    @IBOutlet weak var lblTituloRuta: UILabel!
    @IBOutlet weak var mapa: MKMapView!
    
    private let locationManager = CLLocationManager()
    private let myPicker = UIImagePickerController()
    
    @IBAction func tomarFoto() {
        if (self.selectedAnnotationTitle == nil || self.selectedAnnotationTitle == "") {
            let alertaErrorFotografia = UIAlertController(title: "Error", message: "Selecciona un Pin", preferredStyle: .Alert)
            let accionErrorFotografia = UIAlertAction(title: "Ok", style: .Default, handler: {accion in } )
            alertaErrorFotografia.addAction(accionErrorFotografia)
            self.presentViewController(alertaErrorFotografia, animated: true, completion: nil)
            
            return
        }
        let alertaFotografia = UIAlertController(title: "Fuente", message: "Elige", preferredStyle: UIAlertControllerStyle.Alert);
        alertaFotografia.addAction(UIAlertAction(title: "Camara", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            self.obtenerFotografiaCamara()
            
        }));
        alertaFotografia.addAction(UIAlertAction(title: "Album", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            self.obtenerFotografiaCarrete()
            
        }));
        
        presentViewController(alertaFotografia, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if (self.ruta != nil) {
            self.lblTituloRuta.text = self.ruta!.titulo
        }
        if (self.selectedImage != nil) {
            self.guardarFotografia()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Inicializar mapa.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapa.delegate = self
        self.mapa.showsUserLocation = true
        
        myPicker.delegate = self
        
        if (self.ruta!.puntosEnLaRuta.count > 0) {
            for punto in self.ruta!.puntosEnLaRuta {
                let elementoMapa = self.convertirMKMapItem(punto)
                self.anotaPunto(elementoMapa)
                self.obtenerRuta()
            }
        }
        longPressGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func obtenerFotografiaCamara() {
        myPicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(myPicker, animated: true, completion: nil)
    }
    
    func obtenerFotografiaCarrete() {
        myPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(myPicker, animated: true, completion: nil)
    }
    
    func guardarFotografia() {
        UIImageWriteToSavedPhotosAlbum(self.selectedImage!, nil, nil, nil)
        let indicePunto: Int = (self.ruta?.obtenerIndicePorTitulo(self.selectedAnnotationTitle!))!
        self.ruta?.puntosEnLaRuta[indicePunto].image = self.selectedImage!
        self.selectedImage = nil
        
        let alerta = UIAlertController(title: "Listo", message: "Foto Guardada en el album", preferredStyle: .Alert)
        let accionOk = UIAlertAction(title: "Ok", style: .Default, handler: {accion in } )
        alerta.addAction(accionOk)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func longPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.minimumPressDuration = 2.0
        self.mapa.addGestureRecognizer(longPress)
    }
    
    func longPressAction(gestureRecognizer:UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.Began) {
            let touchPoint = gestureRecognizer.locationInView(self.mapa)
            let newCoord:CLLocationCoordinate2D = self.mapa.convertPoint(touchPoint, toCoordinateFromView: self.mapa)
            var titulo : String?
            let alert = UIAlertController(title: "Agregar", message: "Titulo descriptivo", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler(nil);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                let fields = alert.textFields!;
                titulo = fields[0].text!;
                let punto : Punto = Punto(anotacion: newCoord, titulo: titulo!)
                self.ruta!.agregarElemento(punto)
                let elementoMap = self.convertirMKMapItem(punto)
                self.anotaPunto(elementoMap)
                self.obtenerRuta()
                
            }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func anotaPunto(punto: MKMapItem) {
        let anota = MKPointAnnotation()
        anota.coordinate = punto.placemark.coordinate
        anota.title = punto.name
        mapa.addAnnotation(anota)
    }
    
    func convertirMKMapItem(coordenada : Punto) -> MKMapItem {
        let puntoLugar = MKPlacemark(coordinate: coordenada.anotacion, addressDictionary: nil )
        let origen = MKMapItem(placemark: puntoLugar)
        origen.name = coordenada.titulo
        return origen
    }
    
    func obtenerRuta() {
        
        let elementos = self.ruta!.puntosEnLaRuta.count
        if (elementos > 1) {
            let solicitud = MKDirectionsRequest()
            let index : Int = elementos - 2
            let locMark = MKPlacemark(coordinate: self.ruta!.puntosEnLaRuta[index].anotacion, addressDictionary: nil)
            let destMark = MKPlacemark(coordinate: self.ruta!.puntosEnLaRuta.last!.anotacion, addressDictionary: nil)
            solicitud.source = MKMapItem(placemark: locMark)
            solicitud.destination = MKMapItem(placemark: destMark)
            solicitud.transportType = .Walking
            let indicaciones = MKDirections(request: solicitud)
            indicaciones.calculateDirectionsWithCompletionHandler({
                (respuesta: MKDirectionsResponse?, error: NSError?) in
                if error != nil {
                    print("Error al obtener la ruta")
                } else {
                    self.muestraRuta(respuesta!)
                }
            })
            
        }
    }
    
    func muestraRuta(respuesta: MKDirectionsResponse) {
        
        for ruta in respuesta.routes {
            self.mapa.addOverlay(ruta.polyline, level: MKOverlayLevel.AboveRoads)
        }
        
        let centro = self.ruta!.puntosEnLaRuta.last!.anotacion
        let region = MKCoordinateRegionMakeWithDistance(centro, 0.001, 0.001)
        self.mapa.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        self.mapa.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            self.selectedAnnotationTitle = annotation.title!
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.selectedImage = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
