//
//  UIViewController+Extension.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 02/08/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertMessage() {
        let alertVc = UIAlertController(title: "Error", message: "Error retrieving data", preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertVc, animated: true)
    }
}
