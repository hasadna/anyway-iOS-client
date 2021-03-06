//
//  MainViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 15/05/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import MaterialComponents.MaterialButtons
//import MaterialComponents.MaterialButtons_Theming

class MainViewController: BaseViewController {

    private var gradientStartPoints = [0.0002, 0.02] as [NSNumber]
    //private let BUTTON_Y:CGFloat = 95.0 // FOR TOP
    private let BUTTON_Y:CGFloat = 80.0 // FOR DOWN
    private let BUTTON_HEIGHT:CGFloat = 30.0
    private let BUTTON_WIDTH:CGFloat = 100.0

    private var addressLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!

    var mainViewModel: MainViewOutput! //MainViewModel
    private var gradientColors = [UIColor.green, UIColor.red]
   // private var gradientStartPoints = [0.008, 0.02] as [NSNumber]
   //  private var gradientStartPoints = [0.01, 0.01] as [NSNumber] //old
    //private var gradientStartPoints = [0.01, 0.9] as [NSNumber] // demo
    private var heatmapLayer: GMUHeatmapTileLayer!
    //private var snackbarView = SnackBarView()
    private var helpButton: MDCFloatingButton!
    private var filterButton: MDCFloatingButton!
    private var topDrawer: TopDrawer?
    private var addImageModel: AddImageOutput! //AddImageViewModel

    private var drawerType: DrawerType  = .buttom
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mainViewModel = MainViewModel(viewController: self) /injected instead
        addImageModel = AddImageViewModel(viewController: self)
        mainViewModel.viewDidLoad()
    }
   

    override func setupView() {
        self.navigationController?.isNavigationBarHidden = true
        self.setupMapView()
        self.topDrawer = TopDrawer(frame: CGRect.zero, drawerType: self.drawerType)
        self.view.addSubview(topDrawer!)
    }

    private func setupMapView() {
        mapView.isTrafficEnabled   = false
        mapView.isHidden           = false
        mapView.delegate           = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        if self.drawerType == .buttom {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)// FOR DOWN
        }
        mapView.settings.compassButton = true
        setupHelpButton()
        setupFilterButton()
        setupAdressLabel()
        mapView.animate(toZoom: Config.ZOOM)
    }

    private func setupHelpButton() {
        var buttonY: CGFloat = 130
        if self.drawerType == .top {
            buttonY = 160
        }
        helpButton = MDCFloatingButton(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: buttonY, width: 26, height: 26))
        helpButton.setImage(#imageLiteral(resourceName: "information"), for: .normal)
        helpButton.backgroundColor = UIColor.white
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        helpButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
                //helpButton.layer.borderWidth  = 6 // not working TODO ?
               //helpButton.layer.borderColor = UIColor.black.cgColor
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        self.view.addSubview(helpButton)
    }

    private func setupFilterButton() {
        var buttonY: CGFloat = 130
        if self.drawerType == .top {
            buttonY = 160
        }
        filterButton = MDCFloatingButton(frame: CGRect(x: UIScreen.main.bounds.minX + 30 , y: buttonY, width: 23, height: 23))
        filterButton.setImage(#imageLiteral(resourceName: "filter_add"), for: .normal)
        filterButton.backgroundColor = UIColor.white
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .normal)
        filterButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        filterButton.addTarget(self, action: #selector(filterButtonTap), for: .touchUpInside)
        self.view.addSubview(filterButton)
    }

    
    
    private func setupAdressLabel() {
        var buttonY: CGFloat = 70
        if self.drawerType == .top {
            buttonY = UIScreen.main.bounds.size.height - 70
        }
        
        addressLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.minX + 70 , y: buttonY, width: UIScreen.main.bounds.size.width - 140, height: 30))

        addressLabel.backgroundColor = UIColor.pink//.withAlphaComponent(0.825)
        addressLabel.layer.cornerRadius = 6.0
        addressLabel.layer.masksToBounds = true
       // addressLabel.layer.borderWidth = 1.0
        addressLabel.layer.borderColor = UIColor.black.cgColor
        
        addressLabel.textColor = UIColor.f8BlackText
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textAlignment = .center
        self.view.addSubview(addressLabel)
    }
    
    private func enableFilterAndHelpButtons(){
        filterButton.isEnabled = true;
        helpButton.isEnabled = true;
    }

    private func addMarkers(markers: [MarkerAnnotation]) {
        for marker in markers {
            let googleMarker: GMSMarker = GMSMarker() // Allocating Marker
            googleMarker.title =  marker.title ?? ""
            googleMarker.snippet = marker.subtitle ?? ""
            googleMarker.appearAnimation = .pop // Appearing animation
            googleMarker.position = marker.coordinate
            DispatchQueue.main.async {
                googleMarker.map = self.mapView
            }
        }
    }

    @objc private func helpButtonTapped(_ sender: UIButton) {
        mainViewModel?.handleHelpTap()
    }
    @objc private func filterButtonTap(_ sender: UIButton) {
        mainViewModel?.handleFilterTap()
    }
    @objc private func nextButtonTapped(_ sender: Any) {
        let mapRectangle: GMSVisibleRegion = mapView.projection.visibleRegion()
        mainViewModel.handleNextButtonTap(mapRectangle) //Loading annotations
    }
    @objc private func cancelButtonTapped(_ sender: Any) {
        mainViewModel.handleCancelButtonTap()
    }
    @objc private func reportButtonTapped(_ sender: Any) {
        //addImageModel.showSelectImageAlert(true)
        mainViewModel.handleReportButtonTap()
    }
    @objc private func continueAfterPickingANewPlace(_ sender: Any) {
        mainViewModel.handleContinueAfterPickingANewPlace()
    }
    @objc private func cancelAfterPickingANewPlace(_ sender: Any) {
        mainViewModel.handleCancelAfterPickingANewPlace()
    }
    
    

    private func addTwoButtons(toView: UIView?,
                               firstButtonText: String,
                               secondButtonText: String,
                               firstButtonAction: Selector,
                               secondButtonAction: Selector) {

        toView?.subviews.forEach({ $0.removeFromSuperview() })

        //let buttonY = UIScreen.main.bounds.size.height - self.BIG_DRAWER_HEIGHT  - self.BIG_DRAWER_BUTTON_HEIGHT_OFFSET
        let buttonY =  BUTTON_Y //self.BIG_DRAWER_HEIGHT  - self.BIG_DRAWER_BUTTON_HEIGHT_OFFSET
        //let firstButtonX = UIScreen.main.bounds.size.width/2 + 10
        
        let firstButtonX = UIScreen.main.bounds.size.width/2  - 10 - BUTTON_WIDTH
        let firstButton = MDCFloatingButton(frame: CGRect(x: firstButtonX, y: buttonY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
        firstButton.setTitle(firstButtonText, for: UIControl.State.normal)
        firstButton.backgroundColor = UIColor.lightGray
        firstButton.setTitleColor(UIColor.white, for: .normal)
        firstButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        firstButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        firstButton.addTarget(self, action: firstButtonAction, for: .touchUpInside)

        //let secondButtonX = UIScreen.main.bounds.size.width/2 - 110
        let secondButtonX = UIScreen.main.bounds.size.width/2 + 10
        let secondButton = MDCFloatingButton(frame: CGRect(x: secondButtonX, y: buttonY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
        secondButton.setTitle(secondButtonText, for: UIControl.State.normal)
        secondButton.backgroundColor = UIColor.lightGray
        secondButton.setTitleColor(UIColor.white, for: .normal)
        secondButton.setElevation(ShadowElevation(rawValue: 8), for: .normal)
        secondButton.setElevation(ShadowElevation(rawValue: 12), for: .highlighted)
        secondButton.addTarget(self, action: secondButtonAction, for: .touchUpInside)

        toView?.addSubview(firstButton)
        toView?.addSubview(secondButton)
    }
}

// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mainViewModel?.handleCameraMovedToPosition(coordinate: position.target)
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: Config.ZOOM)
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mainViewModel?.handleTapOnTheMap(coordinate: coordinate)
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}

// MARK: - MainViewInput
extension MainViewController : MainViewInput {

    func showImagPickerScreen(_ pickerController: UIImagePickerController, animated: Bool) {
        self.present(pickerController, animated: animated)
    }


    
    func pushViewController(_ vc: UIViewController, animated: Bool) {
        if  let  navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: animated)
        }
        else{
            print("ERROR - pushViewController - no navigation controller")
        }
        
    }
    
    func popViewController( animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func addCoordinateListToHeatMap(coordinateList: [GMUWeightedLatLng]) {
        // Add the latlng list to the heatmap layer.
        heatmapLayer.weightedData = coordinateList
        self.heatmapLayer.map = self.mapView
    }
    
    func addMarkerstoMap(markers: [NewMarker]) {
       // self.mapView.addAno
    }

    func removeHeatMapLayer() {
        heatmapLayer.map = nil
        heatmapLayer = nil
    }

    func addHeatMapLayer() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 100
        heatmapLayer.opacity = 0.6
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints,colorMapSize: 256)
    }

    func disableFilterAndHelpButtons(){
        filterButton.isEnabled = false;
        helpButton.isEnabled = false;
    }


    func setActionForState(state: MainVCState) {

        switch state {
        case .start:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.enableFilterAndHelpButtons()
                self.mapView.clear()
                self.topDrawer?.subviews.forEach({ $0.removeFromSuperview() })
                self.topDrawer?.setText(text: "CHOOSE_A_PLACE".localized, drawerHeight: Config.SMALL_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)
            }
        case .placePicked:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.disableFilterAndHelpButtons()
                self.addTwoButtons(toView: self.topDrawer,
                              firstButtonText: "CANCEL".localized,
                              secondButtonText:  "CONTINUE".localized,
                              firstButtonAction: #selector(self.cancelButtonTapped ),
                              secondButtonAction: #selector(self.nextButtonTapped))

                self.topDrawer?.setText(text: "TAP_CONTINUE_TO_GET_DANGEROUS_PLACES".localized, drawerHeight: Config.BIG_DRAWER_HEIGHT)
                 self.topDrawer?.setVisibility(visible: true)
            }
        case .continueTappedAfterPlacePicked:
            DispatchQueue.main.async { [weak self]  in
                self?.topDrawer?.setVisibility(visible: false)

            }
        case .markersReceived:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return  }
                self.addTwoButtons(toView: self.topDrawer,
                                   firstButtonText:  "CANCEL".localized,
                                   secondButtonText: "CONTINUE_TO_INFORM".localized,
                                   firstButtonAction: #selector(self.cancelButtonTapped),
                                   secondButtonAction: #selector(self.reportButtonTapped ))

                self.topDrawer?.setText(text:"PLACES_MAKRKED_WITH_HEATMAP".localized, drawerHeight: Config.BIG_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)
            }
        case .reportTapped:
            DispatchQueue.main.async { [weak self]  in
                //self?.topDrawer?.setVisibility(visible: false)
                self?.addImageModel.showSelectImageAlert(true)
            }
            
        case .requestToChangePlace:
            DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.disableFilterAndHelpButtons()
                self.mapView.clear()
                self.topDrawer?.subviews.forEach({ $0.removeFromSuperview() })
                self.topDrawer?.setText(text: "CHOOSE_A_NEW_PLACE".localized, drawerHeight: Config.SMALL_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)
            }
            
        case .placePickedAfterRequestToChangeLoc:
            
             DispatchQueue.main.async { [weak self]  in
                guard let self = self else { return }
                self.addTwoButtons(toView: self.topDrawer,
                                   firstButtonText:  "CANCEL".localized,
                                   secondButtonText: "CONTINUE".localized,
                                   firstButtonAction: #selector(self.cancelAfterPickingANewPlace),
                                   secondButtonAction: #selector(self.continueAfterPickingANewPlace ))
                self.topDrawer?.setText(text: "CONTINUE_TO_CHANGE_LOCATION".localized, drawerHeight: Config.BIG_DRAWER_HEIGHT)
                self.topDrawer?.setVisibility(visible: true)

            }

        }
   
    }

    func setCameraPosition(coordinate : CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: Config.ZOOM, bearing: 0, viewingAngle: 0)
    }

    func setAddressLabel(address: String) {
        self.addressLabel.text = address
    }

    func setMarkerOnTheMap(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // marker.snippet = ""
        marker.map = self.mapView
    }
    
    func clearMap() {
       self.mapView.clear()
    }
}

// MARK: - AddImageInput
extension MainViewController: AddImageInput {

    func setSelectedImage(image: UIImage) {
        mainViewModel.handleSelectedImage(image: image)
    }
    func skipSelectedWhenAddingImage() {
        mainViewModel.handleSkipSelectedWhenAddingImage()
    }
}
