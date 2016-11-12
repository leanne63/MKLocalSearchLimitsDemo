//
//  ViewController.swift
//  zMKLocalSearchLimitsDemo
//
//  Created by leanne on 11/11/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
	
	/*
		Demo MKLocalSearch limits:
		1) Single search, returns only 10 results
		2) Multiple searches, throttled after 35
	*/

	// MARK: - Properties
	
	@IBOutlet weak var mapView: MKMapView!
	
	let completedMultipleSearchesNotification = "CompletedMultipleSearchesNotification"
	var multipleCoffeeIsDone = false
	var multipleGroceryIsDone = false
	
	let arraySize: Int = 151
	var searchResultsCoffee = Array(repeating: "", count: 151) {
		didSet {
			if !searchResultsCoffee.contains("") {
				multipleCoffeeIsDone = true
				let userInfo = ["searchTerm": "coffee"]
				let notification = Notification(name: Notification.Name(rawValue: completedMultipleSearchesNotification),
				                                object: nil, userInfo: userInfo)
				OperationQueue.main.addOperation {
					NotificationCenter.default.post(notification)
				}
			}
		}
	}

	var searchResultsGrocery = Array(repeating: "", count: 151) {
		didSet {
			if !searchResultsGrocery.contains("") {
				multipleGroceryIsDone = true
				let userInfo = ["searchTerm": "grocery"]
				let notification = Notification(name: Notification.Name(rawValue: completedMultipleSearchesNotification),
				                                object: nil, userInfo: userInfo)
				OperationQueue.main.addOperation {
					NotificationCenter.default.post(notification)
				}
			}
		}
	}

	
	
	// MARK: - Lifecycle Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(completedMultipleSearches(notification:)),
		                                       name: NSNotification.Name(rawValue: completedMultipleSearchesNotification),
		                                       object: nil)
		
		setMapRegion()
		
		singleSearchToReturn10Results(searchText: "coffee")
		singleSearchToReturn10Results(searchText: "grocery")
		
		multipleSearchesToDemoThrottling(searchText: "coffee")
		multipleSearchesToDemoThrottling(searchText: "grocery")
	}
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - Utility Functions
	
	func setMapRegion() {
		
		let lat: CLLocationDegrees = 38.627003
		let lon: CLLocationDegrees = -90.199402
		let centerCoordinate = CLLocationCoordinate2DMake(lat, lon)
		
		let latDelta: CLLocationDegrees = 0.05
		let lonDelta: CLLocationDegrees = 0.05
		let span = MKCoordinateSpanMake(latDelta, lonDelta)
		
		let mapRegion: MKCoordinateRegion =
			MKCoordinateRegionMake(centerCoordinate, span)
		
		mapView.setRegion(mapRegion, animated: true)
	}

	
	func singleSearchToReturn10Results(searchText: String) {
		
		let searchRequest = MKLocalSearchRequest()
		searchRequest.naturalLanguageQuery = searchText
		searchRequest.region = mapView.region
		
		let search = MKLocalSearch(request: searchRequest)
		
		search.start {
			(response, error) in
			
			guard error == nil else {
				print("*** Error retrieving search results:\n\(error!)")
				let errorMessage: String = self.getSpecificMessage(forError: error!)
				print("*** Error code indicates more specifically: \(errorMessage)")
				return
			}
			
			guard let response = response else {
				print("*** No response provided while retrieving search results\n\(error)")
				return
			}
			
			print("***** Search for \(searchText) returned \(response.mapItems.count) results. *****")
		}
	}
	
	
	func multipleSearchesToDemoThrottling(searchText: String) {
		
		var stopLocs = [CLLocationCoordinate2D]()
		
		// load a number of "stop" locations
		var lat: CLLocationDegrees = 38.592869
		var lon: CLLocationDegrees = -90.319436
		
		for _ in 0..<arraySize {
			let stopLoc = CLLocationCoordinate2DMake(lat, lon)
			
			stopLocs.append(stopLoc)
			
			lat += 0.000002
			lon += 0.000002
			
			// note: this is to demonstrate that this is not an endless loop, ie "buggy code"
			//	my app uses actual transit stop coordinates, which might be close in distance, but still different
		}
		
		// iterate through the stop locations to find nearby search results
		for (idx, stopLoc) in stopLocs.enumerated() {
			
			let searchRequest = MKLocalSearchRequest()
			searchRequest.naturalLanguageQuery = searchText
			
			// set up center coordinate based on stop location, and set distance from center in meters
			let thisCenterCoord: CLLocationCoordinate2D = stopLoc
			let distance: CLLocationDistance = 300.0
			
			let coordinateRegion = MKCoordinateRegionMakeWithDistance(thisCenterCoord, distance, distance)
			searchRequest.region = coordinateRegion
			
			let search = MKLocalSearch(request: searchRequest)
			
			search.start {
				(response: MKLocalSearchResponse?, error: Error?) in
				
				guard error == nil else {
					let msgPart1 = "*** Search \(idx) for \(searchText) received error:\n\(error!)"
					let errorMessage: String = self.getSpecificMessage(forError: error!)
					let msgPart2 = "*** Error code indicates more specifically: \(errorMessage)"
					
					switch searchText {
					case "coffee":
						self.searchResultsCoffee[idx] = "\(msgPart1)\n\(msgPart2)\n"
					case "grocery":
						self.searchResultsGrocery[idx] = "\(msgPart1)\n\(msgPart2)\n"
					default:
						break
					}
					return
				}
				
				guard let response = response else {
					print("*** No response provided while retrieving search results\n\(error)")
					return
				}
				
				switch searchText {
				case "coffee":
					self.searchResultsCoffee[idx] =
						"***** Search \(idx) for \(searchText) returned \(response.mapItems.count) results. *****"
				case "grocery":
					self.searchResultsGrocery[idx] =
						"***** Search \(idx) for \(searchText) returned \(response.mapItems.count) results. *****"
				default:
					break
				}
			}
		}
	}
	
	
	func completedMultipleSearches(notification: Notification) {
		
		let userInfo = notification.userInfo as! [String: String]
		let searchTerm: String = userInfo["searchTerm"]!
		
		switch searchTerm {
		case "coffee":
			for idx in 0..<searchResultsCoffee.count {
				print("*** \(idx): \(searchResultsCoffee[idx])")
			}
		
		case "grocery":
			for idx in 0..<searchResultsGrocery.count {
				print("*** \(idx): \(searchResultsGrocery[idx])")
			}
			
		default:
			break
		}
		
		if multipleCoffeeIsDone && multipleGroceryIsDone {
			displayAlert()
		}
	}
	
	
	func displayAlert() {
		
		let alertView = UIAlertController(title: "Searches Complete",
		                                  message: "Multiple search sequences have all completed!",
		                                  preferredStyle: UIAlertControllerStyle.alert)
		let alertOKAction = UIAlertAction(title: "Title",
		                                  style: UIAlertActionStyle.default,
		                                  handler: nil)
		alertView.addAction(alertOKAction)
		
		present(alertView, animated: true, completion: nil)
	}
	
	
	func getSpecificMessage(forError error: Error) -> String {
		
		let nsError = (error as NSError)
		let errorCode = UInt(abs(nsError.code))
		
		var errorMessage = ""
		
		switch errorCode {
			
		case MKError.unknown.rawValue:
			errorMessage = "MKError.unknown"
			
		case MKError.serverFailure.rawValue:
			errorMessage = "MKError.serverFailure"
			
		case MKError.loadingThrottled.rawValue:
			errorMessage = "MKError.loadingThrottled"
			
		case MKError.placemarkNotFound.rawValue:
			errorMessage = "MKError.placemarkNotFound"
			
		case MKError.directionsNotFound.rawValue:
			errorMessage = "MKError.directionsNotFound"
			
		default:
			errorMessage = "unknown"
		}
		
		return errorMessage
	}
}

