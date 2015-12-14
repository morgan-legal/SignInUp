//
//  SearchPlaceTableViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/29/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit


class SearchPlaceTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate {

    @IBOutlet var searchResultTableView: UITableView!
    
    var searchResults: [GMSAutocompletePrediction] = []
    
    var shouldShowSearchResults = false

    
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    
    let filter = GMSAutocompleteFilter()
    
    var isValidPlace = false
    
    @IBOutlet weak var nextStepBarButton: UIBarButtonItem!
    
    var placeVisited: Pin!
    var country: String!
    var city: String!
    var coordinates: PFGeoPoint!
    let placesClient = GMSPlacesClient()
    var placesIDs: [String] = []

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
  
        
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!
        ]
        
        //navBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x326094)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filter.type = GMSPlacesAutocompleteTypeFilter.City
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self

        configureSearchController()
        configureCustomSearchController()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return self.searchResults.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)
        
        if shouldShowSearchResults {
            cell.textLabel?.text = self.searchResults[indexPath.row].attributedFullText.string
        }
        else {
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        updatePinPropertiesFromPlaceID( self.searchResults[indexPath.row].placeID ) {
            place in
                self.placeVisited = place
                self.customSearchController.customSearchBar.text = place.city + ", " + place.country
                self.isValidPlace = true
                self.nextStepBarButton.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func nextStepBarButtonPressed(sender: UIBarButtonItem) {
        if self.isValidPlace && self.placeVisited.isVisited {
           self.performSegueWithIdentifier("toAddPlaceVisitedStep2Segue", sender: self)
        }
        else if self.isValidPlace == true && self.placeVisited.isVisited == false {
            self.performSegueWithIdentifier("toAddPlaceToVisitStep2Segue", sender: self)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAddPlaceVisitedStep2Segue" {
            let placeVisitedVC: PlaceVisitedViewController = segue.destinationViewController as! PlaceVisitedViewController

            placeVisitedVC.placeVisited = self.placeVisited
            
            //placeVisitedVC.delegate = self
        }
        else if segue.identifier == "toAddPlaceToVisitStep2Segue" {
            let placeVisitedVC: PlaceVisitedViewController = segue.destinationViewController as! PlaceVisitedViewController
            
            placeVisitedVC.placeVisited = self.placeVisited
            
            //placeVisitedVC.delegate = self
        }
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchResultTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        searchResultTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            searchResultTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating delegate function
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        let searchString = searchController.searchBar.text
//        
//        if searchString != "" {
//            
//            let filter = GMSAutocompleteFilter()
//            filter.type = GMSPlacesAutocompleteTypeFilter.City
//            
//            self.placesClient.autocompleteQuery( searchString!, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
//                if let error = error {
//                    print("Autocomplete error \(error)")
//                }
//                self.searchResults = (results as? [GMSAutocompletePrediction])!
//                for result in (results as? [GMSAutocompletePrediction])! {
//                    self.placesIDs.append(result.placeID)
//                }
//            })
//            searchResultTableView.reloadData()
//        }
    }
    
    
    // MARK: CustomSearchControllerDelegate functions
    
    func didStartSearching() {
        shouldShowSearchResults = true
        searchResultTableView.reloadData()
    }
    
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            searchResultTableView.reloadData()
        }
    }
    
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        searchResultTableView.reloadData()
    }
    
    
    // MARK: Helper functions
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame = CGRectMake(0.0, 0.0, searchResultTableView.frame.size.width, 50.0)
        searchController.searchBar.barTintColor = UIColorFromRGB(0x5DA1FE)
        // Place the search bar view to the tableview headerview.
        searchResultTableView.tableHeaderView = searchController.searchBar
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, searchResultTableView.frame.size.width, 50.0), searchBarFont: UIFont(name: "AvenirNext-Bold", size: 16.0)!, searchBarTextColor: UIColorFromRGB(0x5DA1FE), searchBarTintColor: UIColorFromRGB(0xDEEDFE) )
        
        //customSearchController.customSearchBar.placeholder = "Where did you go ?"
        let searchTextfield:UITextField = customSearchController.customSearchBar.valueForKey("searchField") as! UITextField
        let attributedString = NSAttributedString(string: "Where did you go ?", attributes: [NSForegroundColorAttributeName : UIColorFromRGB(0x5DA1FE)])
        searchTextfield.attributedPlaceholder = attributedString
        customSearchController.customSearchBar.tintColor = UIColor.whiteColor()
        searchResultTableView.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func didChangeSearchText(searchText: String) {
        autoCompleteTextFromQuery( searchText ) {
            results in
            self.searchResults = results
            self.searchResultTableView.reloadData()
        }
    }
    
    func autoCompleteTextFromQuery (searchText: String, callback: ([GMSAutocompletePrediction]) -> ()) {
        if searchText != "" {
            self.placesClient.autocompleteQuery( searchText, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
                
                if let error = error {
                    print("Autocomplete error \(error)")
                }
                
                let searchResults = (results as? [GMSAutocompletePrediction])!
                
                for result in (results as? [GMSAutocompletePrediction])! {
                    self.placesIDs.append(result.placeID)
                }
                
                callback( searchResults )
            })
        }
    }
    
    func updatePinPropertiesFromPlaceID (placeID: String, callback: (Pin) -> ())
    {
        var city: String!
        var country: String!
        var coordinates: PFGeoPoint!
        
        self.placesClient.lookUpPlaceID(placeID, callback:
            { (place, error) -> Void in
                if error != nil {
                    print("lookup place id query error: \(error!.localizedDescription)")
                    return
                }
                if let p = place {
                    var resultStringArray = p.formattedAddress.componentsSeparatedByString(", ")
                    
                    city = p.name
                    
                    
                    if resultStringArray.count > 2 {
                        country = resultStringArray[2]
                    }
                    else {
                        country = resultStringArray[1]
                    }
                    
                    coordinates = PFGeoPoint(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
 
                }
                else {
                    print("No place details for \(placeID)")
                }
              //  callback( Pin(userId: (currentUser()?.id)!, isVisited: true, city: city, country: country, coordinates: coordinates) )
        })
    }

}
