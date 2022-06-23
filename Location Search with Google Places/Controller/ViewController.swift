//
//  ViewController.swift
//  Location Search with Google Places
//
//  Created by Ioanna Karageorgou on 22/6/22.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: ResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Maps"
        view.addSubview(mapView)
        
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top,
                               width: view.frame.size.width,
                               height: view.frame.size.height - view.safeAreaInsets.top)
        
        // maybe bar color?
    }
    
    //MARK: - UISearch Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let resultsVC = searchController.searchResultsController as? ResultsViewController
        else {
            return
        }
        
        resultsVC.delegate = self
                
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
//                print(places)
                
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension ViewController: ResultsViewControllerDelegate {
    
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        // remove keybord
        searchVC.searchBar.resignFirstResponder()
        
        searchVC.dismiss(animated: true)
        
        // remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)

        // add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(
                                    latitudeDelta: 0.2,
                                    longitudeDelta: 0.2)),
                            animated: true)
        
    }
    
}
