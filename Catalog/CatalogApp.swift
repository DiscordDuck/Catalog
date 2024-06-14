//
//  CatalogApp.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-05-27.
//

import SwiftUI

@main
struct CatalogApp: App {

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case itemNotFound
        case unknown(OSStatus)
    }
    
    static func save(
        account: String,
        password: String,
        consentForm: [Any] = [],
        invoice: [Any] = []
    ) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: ([password, consentForm, invoice] as [Any]).description.data(using: .utf8) as AnyObject,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            do {
                try replace(account: account, password: password, consentForm: consentForm, invoice: invoice)
                return
            }
            catch {
                throw KeychainError.duplicateEntry
            }
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    static func replace(
        account: String,
        password: String,
        consentForm: [Any] = [],
        invoice: [Any] = []
    ) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: ([password, consentForm, invoice] as [Any]).description.data(using: .utf8) as AnyObject,
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    static func get(
        account: String
    ) throws -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
            
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        return result as? Data
    }
}
