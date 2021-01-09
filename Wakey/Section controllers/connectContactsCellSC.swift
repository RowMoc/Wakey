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
    
    func connectPressed(cell: connectContactsCell) {
        print("ACCESS GRANTED")
        self.downloadContacts(cell: cell)
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
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow Wakey to access your contacts through Settings."
                            self.showMessage(message: message)
                        }
                    }
                }
            }
        default:
            completionHandler(false)
        }
    }

    func downloadContacts(cell: connectContactsCell) {
        DispatchQueue.main.async {
            self.requestForAccess { (accessGranted) -> Void in
                if accessGranted {
                    DispatchQueue.main.async {
                        cell.beginLoadingView()
                    }
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
                    var contacts = [CNContact]()
                    var sanitizedPhoneNums = [String]()
                    var message: String!
                    
                    let contactsStore = CNContactStore()
                    do {
                        try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])) {
                            (contact, cursor) -> Void in
                            if !contact.phoneNumbers.isEmpty {
                                let firstNum = contact.phoneNumbers[0] as CNLabeledValue<CNPhoneNumber>
                                let phoneNumberStruct = firstNum.value as CNPhoneNumber
                                let phoneNumberString = phoneNumberStruct.stringValue
                                let name = contact.givenName + " " + contact.familyName
                                let sanitizedNum = phoneNumberString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                                let lastNineSanNum = String(sanitizedNum.suffix(9))
                                sanitizedPhoneNums.append(lastNineSanNum)
                            }
                        }
                    }
                    catch {
                        message = "Unable to fetch contacts"
                    }

                    if message != nil {
                        DispatchQueue.main.async {
                            self.showMessage(message: message)
                        }
                    } else {
                        // Success
                        DispatchQueue.main.async {
                            self.findUsersFromContacts(numbers: sanitizedPhoneNums, cell: cell)
                        }
                    }
                }
            }
        }
    }
    
    
    func findUsersFromContacts(numbers: [String], cell: connectContactsCell) {
        FirebaseManager.shared.findFriendsFromContacts(numbersToSearchFor: numbers) { (error, foundUsers) in
            guard let vc = self.viewController as? searchFriendsVC else {
                return
            }
            if error != nil {
                vc.askToConnectContacts = false
                vc.foundUsersInContacts = false
                vc.adapter.performUpdates(animated: true)
            } else {
                vc.askToConnectContacts = false
                vc.foundUsersInContacts = true
                vc.foundInContacts = foundUsers
                vc.adapter.performUpdates(animated: true)
            }
        }
    }
    
}
