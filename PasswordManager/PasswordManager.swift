//  Copyright © 2017 Compass. All rights reserved.

import Foundation
import UIKit
import MobileCoreServices

public enum PasswordManagerError: Error {
    case usernameNotFound
    case passwordNotFound
    case extensionCancelledByUser
    case extensionNoAttachments
    case extensionUnexpectedData
}

class PasswordManager {
    private let versionNumber = 184
    static let shared = PasswordManager()
    private let passwordManagerAvailable: URL = {
        return URL(string: "org-appextension-feature-password-management://")!
    }()

    private init() {}

    var isPasswordManagerAvailable: Bool {
        return UIApplication.shared.canOpenURL(passwordManagerAvailable)
    }

    func findLogin(urlString: String, viewController: UIViewController, sender: UIView, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let item: [String: Any] = [PasswordManagerConstants.VersionNumberKey: versionNumber, PasswordManagerConstants.UrlStringKey: urlString]
        let activityViewController = activityViewControllerForItem(item: item, viewController: viewController, sender: sender, typeIdentifier: PasswordManagerConstants.FindLoginAction)
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, activityError in
            guard let item = returnedItems?.first as? NSExtensionItem else {
                let error = activityError ?? PasswordManagerError.extensionCancelledByUser
                completion(nil, error)
                return
            }

            self?.processExtensionItem(extensionItem: item, completion: { itemDictionary, error in
                DispatchQueue.main.async {
                    completion(itemDictionary, error)
                }
            })
        }
        viewController.present(activityViewController, animated: true, completion: nil)
    }

    func storeLogin(urlString: String, loginDetails: [AnyHashable: Any], passwordGenerationOptions: [AnyHashable: Any], viewController: UIViewController, sender: UIView, completion: @escaping ([String: Any]?, Error?) -> Void) {
        var newLoginAttributes = [AnyHashable: Any]()
        newLoginAttributes[PasswordManagerConstants.VersionNumberKey] = versionNumber
        newLoginAttributes[PasswordManagerConstants.UrlStringKey] = urlString
        for (key, value) in loginDetails {
            newLoginAttributes[key] = value
        }
        if passwordGenerationOptions.count > 0 {
            newLoginAttributes[PasswordManagerConstants.PasswordGeneratorOptionsKey] = passwordGenerationOptions
        }
        let activityViewController = activityViewControllerForItem(item: newLoginAttributes, viewController: viewController, sender: sender, typeIdentifier: PasswordManagerConstants.SaveLoginAction)
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, activityError in
            guard let item = returnedItems?.first as? NSExtensionItem else {
                let error = activityError ?? PasswordManagerError.extensionCancelledByUser
                completion(nil, error)
                return
            }

            self?.processExtensionItem(extensionItem: item, completion: { itemDictionary, error in
                DispatchQueue.main.async {
                    completion(itemDictionary, error)
                }
            })
        }
        viewController.present(activityViewController, animated: true, completion: nil)
    }

    private func activityViewControllerForItem(item: [AnyHashable: Any], viewController: UIViewController, sender: UIView, typeIdentifier: String) -> UIActivityViewController {
        let itemProvider = NSItemProvider(item: item as NSSecureCoding, typeIdentifier: typeIdentifier)
        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [itemProvider]

        let activityViewController = UIActivityViewController(activityItems: [extensionItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender

        return activityViewController
    }

    private func processExtensionItem(extensionItem: NSExtensionItem?, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let itemProvider = extensionItem?.attachments?.first as? NSItemProvider else {
            completion(nil, PasswordManagerError.extensionNoAttachments)
            return
        }

        let propertyListType = kUTTypePropertyList as String
        if !itemProvider.hasItemConformingToTypeIdentifier(propertyListType) {
            completion(nil, PasswordManagerError.extensionUnexpectedData)
            return
        }

        itemProvider.loadItem(forTypeIdentifier: propertyListType, options: nil, completionHandler: { secureCodingItem, _ in
            guard let itemDictionary = secureCodingItem as? [String: Any] else {
                completion(nil, PasswordManagerError.extensionUnexpectedData)
                return
            }
            completion(itemDictionary, nil)
        })
    }
}
