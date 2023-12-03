//
//  ClientAddStep1ViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-09.
//

import UIKit
import RealmSwift
import GooglePlaces

class ClientAddStep1ViewController: BaseScrollingViewController {
    
    private var tempClient: TempClient! {
        didSet {
            birthday = tempClient.birthday
            addressField.text = tempClient.address?.address
            cityField.text = tempClient.address?.city
            provinceField.text = tempClient.address?.province
            zipCodeField.text = tempClient.address?.zipCode
        }
    }
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var quitButton: ThemeBarButton!
    @IBOutlet weak var birthdayField: ThemeTextField!
    @IBOutlet weak var birthdayDropdownButton: DropdownButton!
    @IBOutlet weak var addressField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var zipCodeField: ThemeTextField!
    
    private var birthday: Date? {
        didSet {
            if let birthday = birthday {
                birthdayField.text = DateUtil.convert(input: birthday, outputFormat: .format5)
            } else {
                birthdayField.text = ""
            }
        }
    }
    
    private var street_number: String = ""
    private var route: String = ""
    private var neighborhood: String = ""
    private var locality: String = ""
    private var administrative_area_level_1: String = ""
    private var country: String = ""
    private var postal_code: String = ""
    private var postal_code_suffix: String = ""
    
    override func setup() {
        super.setup()
        
        fieldsGroup.append(addressField)
        fieldsGroup.append(cityField)
        fieldsGroup.append(provinceField)
        fieldsGroup.append(zipCodeField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        addressFilter.country = tempClient.address?.countryCode
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func birthdayDropdownPress(_ sender: UIButton) {
        sender.isSelected = true
        let datePickerDialog = DatePickerDialog()
        datePickerDialog.configure(selected: birthday ?? Date().getPastOrFutureDate(year: -18),
                                   showDimOverlay: true,
                                   overUIWindow: true)
        datePickerDialog.delegate = self
        datePickerDialog.show(inView: view, withDelay: 100)
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(TempClient.self).isEmpty {
            // Create a new TempClient
            tempClient = TempClient(partition: UserManager.shared.userPartitionKey)
            
            do {
                try realm.write {
                    realm.add(tempClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            tempClient = realm.objects(TempClient.self).first
        }
    }
    
    private func fillAddressForm() {
        addressField.text = street_number + " " + route
        cityField.text = locality
        provinceField.text = administrative_area_level_1
        if postal_code_suffix != "" {
            zipCodeField.text = postal_code + "-" + postal_code_suffix
        } else {
            zipCodeField.text = postal_code
        }
        
        do {
            try realm.write {
                tempClient.address?.address = street_number + " " + route
                tempClient.address?.city = locality
                tempClient.address?.province = administrative_area_level_1
                tempClient.address?.zipCode = zipCodeField.text ?? ""
            }
        } catch(let error) {
            print("write error: \(error.localizedDescription)")
        }
        
        // Clear values for next time.
        street_number = ""
        route = ""
        neighborhood = ""
        locality = ""
        administrative_area_level_1  = ""
        country = ""
        postal_code = ""
        postal_code_suffix = ""
    }
}

extension ClientAddStep1ViewController: DatePickerDialogDelegate {
    func dateSelected(date: Date, dialog: DatePickerDialog) {
        birthday = date.startOfDay()
        birthdayDropdownButton.isSelected = false
        
        do {
            try realm.write {
                tempClient.birthday = birthday
            }
        } catch(let error) {
            print("saveTempClientValues \(error.localizedDescription)")
        }
    }
    
    func dismissedDialog(dialog: DatePickerDialog) {
        birthdayDropdownButton.isSelected = false
    }
}

extension ClientAddStep1ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = inputToolbar
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let index = fieldsGroup.firstIndex(of: textField) else {
            print("Error: \(textField) not added to searchFieldsGroup!")
            return
        }
        highlightedFieldIndex = index
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightedFieldIndex = nil
        
        if textField == addressField {
            do {
                try realm.write {
                    tempClient.address?.address = textField.text ?? ""
                }
            } catch(let error) {
                print("write error: \(error.localizedDescription)")
            }
        } else if textField == cityField {
            do {
                try realm.write {
                    tempClient.address?.city = textField.text ?? ""
                }
            } catch(let error) {
                print("write error: \(error.localizedDescription)")
            }
        } else if textField == provinceField {
            do {
                try realm.write {
                    tempClient.address?.province = textField.text ?? ""
                }
            } catch(let error) {
                print("write error: \(error.localizedDescription)")
            }
        } else if textField == zipCodeField {
            do {
                try realm.write {
                    tempClient.address?.zipCode = textField.text ?? ""
                }
            } catch(let error) {
                print("write error: \(error.localizedDescription)")
            }
        }
    }
}

extension ClientAddStep1ViewController: GMSAutocompleteViewControllerDelegate {

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console
        print("Place name: \(place.name ?? "")")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(String(describing: place.attributions))")
        
        // Get the address components.
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                for type in field.types {
                    switch type {
                    case kGMSPlaceTypeStreetNumber:
                        street_number = field.name
                    case kGMSPlaceTypeRoute:
                        route = field.name
                    case kGMSPlaceTypeNeighborhood:
                        neighborhood = field.name
                    case kGMSPlaceTypeLocality:
                        locality = field.name
                    case kGMSPlaceTypeAdministrativeAreaLevel1:
                        administrative_area_level_1 = field.name
                    case kGMSPlaceTypeCountry:
                        country = field.name
                    case kGMSPlaceTypePostalCode:
                        postal_code = field.name
                    case kGMSPlaceTypePostalCodeSuffix:
                        postal_code_suffix = field.name
                    // Print the items we aren't using.
                    default:
                        print("Type: \(type), Name: \(field.name)")
                    }
                }
            }
        }
        
        // Call custom function to populate the address form.
        fillAddressForm()
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
    }
}
