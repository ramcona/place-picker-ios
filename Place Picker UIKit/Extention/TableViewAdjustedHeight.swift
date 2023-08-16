//
//  TableViewAdjustedHeight.swift
//  Place Picker UIKit
//
//  Created by Rafli on 13/08/23.
//

import Foundation
import UIKit

class TableViewAdjustedHeight: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
