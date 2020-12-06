//
//  connectContactsCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/27.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import FBSDKCoreKit
import FBSDKLoginKit
import Contacts


class connectContactsCellSC: ListSectionController, connectContactsCellDelegate {
    
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: connectContactsCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? connectContactsCell {
            cell.delegate = self
        }
        return cell
    }
    
    
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
    }
    
    func connectPressed() {
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                print("ACCESS GRANTED")
                self.searchForContactUsingPhoneNumber(phoneNumber: "")
            } else {
                print("ACCESS NOT GRANTED")
            }
        }
    }
    
    // MARK: - App Logic
    func showMessage(message: String) {
        // Create an Alert
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)

        // Add an OK button to dismiss
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) -> Void in
        }
        alertController.addAction(dismissAction)

        // Show the Alert
        self.viewController?.present(alertController, animated: true, completion: nil)
    }

    func requestForAccess(completionHandler:  @escaping  (_ accessGranted: Bool) -> Void) {
        // Get authorization
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

        // Find out what access level we have currently
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)

        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: CNEntityType.contacts) { (access, accessError) in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async {
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message: message)
                        }
                    }
                }
            }
        default:
            completionHandler(false)
        }
    }

    @IBAction func findContactInfoForPhoneNumber(sender: UIButton) {
        self.searchForContactUsingPhoneNumber(phoneNumber: "(888)555-1212)")
    }

    func searchForContactUsingPhoneNumber(phoneNumber: String) {
        DispatchQueue.main.async {
            self.requestForAccess { (accessGranted) -> Void in
                if accessGranted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
                    var contacts = [CNContact]()
                    var message: String!

                    let contactsStore = CNContactStore()
                    do {
                        try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])) {
                            (contact, cursor) -> Void in
                            if (!contact.phoneNumbers.isEmpty) {
                                print("CONTACT INFO HERE:", contact)
//                                let phoneNumberToCompareAgainst = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
//                                for phoneNumber in contact.phoneNumbers {
//                                    if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
//                                        let phoneNumberString = phoneNumberStruct.stringValue
//                                        let phoneNumberToCompare = phoneNumberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
//                                        if phoneNumberToCompare == phoneNumberToCompareAgainst {
//                                            contacts.append(contact)
//                                        }
//                                    }
//                                }
                            }
                        }

                        if contacts.count == 0 {
                            message = "No contacts were found matching the given phone number."
                        }
                    }
                    catch {
                        message = "Unable to fetch contacts."
                    }

                    if message != nil {
                        DispatchQueue.main.async {
                            self.showMessage(message: message)
                        }
                    } else {
                        // Success
                        DispatchQueue.main.async {
                            // Do someting with the contacts in the main queue, for example
                            /*
                             self.delegate.didFetchContacts(contacts) <= which extracts the required info and puts it in a tableview
                             */
                            print(contacts) // Will print all contact info for each contact (multiple line is, for example, there are multiple phone numbers or email addresses)
                            let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
                            print(contact.givenName) // Print the "first" name
                            print(contact.familyName) // Print the "last" name
                            if contact.isKeyAvailable(CNContactImageDataKey) {
                                if let contactImageData = contact.imageData {
                                    print(UIImage(data: contactImageData)) // Print the image set on the contact
                                }
                            } else {
                                // No Image available

                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
