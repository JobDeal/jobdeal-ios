//
//  SelectAddressViewController.swift
//  JobDeal
//
//  Created by Priba on 1/10/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TransitionButton
import Cosmos
import PWSwitch
import Toast_Swift
import AssetsPickerViewController
import TweeTextField
import GoogleMaps

protocol AddressSelectionDelegate: class{
    
    func selectedCoordinate(coordinate: CLLocationCoordinate2D, address: String)
    
}

class SelectAddressViewController: BaseViewController, GMSMapViewDelegate, LocationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var selectBtn: TransitionButton!
    @IBOutlet weak var aimImageView: UIImageView!
    
    
    
    var userMarker: GMSMarker = GMSMarker()
    weak var delegate: AddressSelectionDelegate?
    var isSelectingFilterAddress = false

    var first = true
    var offer = OfferModel()
    var isEditingLocation: Bool?
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        checkLocation()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Private Methods
    override func setupUI(){
        
        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "add_location", uppercased: true), withGradient: true)
        locationIcon.tintColor = UIColor.darkGray
        aimImageView.tintColor = UIColor.darkGray
        selectBtn.setupForTransitionLayoutTypeBlack()
        
        addressTF.layer.cornerRadius = 10
        addressTF.setLeftPaddingPoints(34)
        addressTF.backgroundColor = UIColor.white
    }
    
    // MARK: - Check location
    func checkLocation() {
        if  offer.latitude != 0.0 {
          let locationOffer =  CLLocationCoordinate2D(latitude: offer.latitude, longitude: offer.longitude)
            mapView.animate(toLocation: locationOffer)
            mapView.animate(toZoom: 15)
            
        } else {
            LocationManager.sharedInstance.startUpdatingAccuratLocation()
            LocationManager.sharedInstance.delegate = self
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.sharedInstance.stopUpdatingLocation()

    }
    
    override func setupStrings(){
        
        addressTF.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "select_address")
        
        if isSelectingFilterAddress{
            selectBtn.setupTitleForKey(key: "add_location", uppercased: true)
        }else{
            selectBtn.setupTitleForKey(key: "apply_address", uppercased: true)
        }
    }
    
    // MARK: - Location
    
    func findLocation() {
        mapView.animate(toLocation: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        mapView.animate(toZoom: 12)
        mapView.setMinZoom(0, maxZoom: 14)
        mapView.padding = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        mapView.layer.cornerRadius = 8

        let marker = GMSMarker.init(position: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icPlaceCopy")
        imageView.tintColor = UIColor.darkGray
        marker.iconView = imageView
        marker.map = mapView
    }

    //MARK: - Button Actions
    @IBAction func selectBtnAction(_ sender: Any) {
        let safetyStr = LanguageManager.sharedInstance.getStringForKey(key: "custome_address")
        delegate?.selectedCoordinate(coordinate: mapView.camera.target, address: addressTF.text == "" ? safetyStr : addressTF.text ?? safetyStr)
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func backBtnAction() {
        super.backBtnAction()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Location Delegate
    
    func didUpdateLocations(newLocation: CLLocation) {
        
        if(first){
            first = false
            self.mapView.animate(toLocation: DataManager.sharedInstance.userLastLocation)
            mapView.animate(toZoom: 13)
        }
        
        if(newLocation.course > 0){
            userMarker.rotation = newLocation.course
        }
        
        userMarker.position = newLocation.coordinate
        
    }
    
    //MARK: - TextField Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        ServerManager.sharedInstance.getAddressWith(longitude: position.target.longitude, latitude: position.target.latitude) { (response, success, errMsg) in
            if let address: String = response["address"] as? String{
                self.addressTF.text = address
            }
            
        }
    }
}
