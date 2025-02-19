//
//  AlertConstructor.swift
//  FakeNFT
//
//  Created by Aleksandr Eliseev on 21.06.2023.
//

import UIKit

protocol AlertDescriptable {
    var description: String { get }
    var style: UIAlertAction.Style { get }
}

protocol AlertConstructable {
    func constructAlert(title: String, style: UIAlertController.Style, error: NetworkError?) -> UIAlertController
    func addLoadErrorAlertActions(from alert: UIAlertController, handler: @escaping (UIAlertAction) -> Void)
    func addSortAlertActions<T: CaseIterable & AlertDescriptable>(for alert: UIAlertController, values: [T], completion: @escaping (T) -> Void)
}

struct AlertConstructor: AlertConstructable {
    func constructAlert(title: String, style: UIAlertController.Style, error: NetworkError?) -> UIAlertController {
        return UIAlertController(
            title: title,
            message: error?.errorDescription,
            preferredStyle: style)
    }
    
    func addLoadErrorAlertActions(from alert: UIAlertController, handler: @escaping (UIAlertAction) -> Void) {
        AlertErrorActions.allCases.forEach { alertCase in
            alert.addAction(
                UIAlertAction(
                    title: alertCase.title,
                    style: alertCase.action,
                    handler: { action in
                        handler(action)
                    }
                )
            )
        }
    }
    
    func addSortAlertActions<T: CaseIterable & AlertDescriptable>(for alert: UIAlertController, values: [T], completion: @escaping (T) -> Void) {
        for value in T.allCases {
            alert.addAction(
                UIAlertAction(
                    title: value.description,
                    style: value.style,
                    handler: { _ in
                        completion(value)
                    }))
        }
    }
}
