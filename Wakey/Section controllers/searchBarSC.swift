//
//  searchBarSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit

protocol searchSCDelegate: class {
    func searchSectionController(_ sectionController: searchBarSC, didChangeText text: String)
}

final class searchBarSC: ListSectionController, UISearchBarDelegate, ListScrollDelegate {

    weak var delegate: searchSCDelegate?
    
    var placeholderText: String?

    override init() {
        super.init()
        scrollDelegate = self
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 50)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell: searchCell = collectionContext?.dequeueReusableCell(withNibName: String(describing: searchCell.self), bundle: Bundle.main, for: self, at: index) as? searchCell else {
            fatalError()
        }
        if let placeholderText = placeholderText {
            cell.searchBar.placeholder = placeholderText
        }
        // SearchBar text
        let textFieldInsideUISearchBar = cell.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont(name: "Avenir-medium", size: 17)
        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.font = UIFont(name: "Avenir-book", size: 17)
        //viewController?.hideKeyboardWhenTappedAround()
        cell.searchBar.delegate = self
        return cell
    }

    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchSectionController(self, didChangeText: searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchSectionController(self, didChangeText: searchBar.text!)
    }

    // MARK: ListScrollDelegate
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
        if let searchBar = (collectionContext?.cellForItem(at: 0, sectionController: self) as? searchCell)?.searchBar {
            searchBar.resignFirstResponder()
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, willBeginDragging sectionController: ListSectionController) {}
    func listAdapter(_ listAdapter: ListAdapter,
                     didEndDragging sectionController: ListSectionController,
                     willDecelerate decelerate: Bool) {}

}
