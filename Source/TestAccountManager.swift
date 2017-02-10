//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// The TestAccountManager handles managing test login accounts for different environments. It also includes support for broadcasting messages in the event an account is selected (i.e. in a menu system, when an account is selected this can than broadcast the selected account and environment so that you can fill in login details automatically)
class TestAccountManager {
    typealias AccountStore = [String:Set<Account>]
    var allAccounts: AccountStore = [:]
    // Default use the NotificationBroadcaster.
    // TOOD: unit tests/ possibly better DI for this (maybe someone doesnt want any broadcaster? or just there own?)
    var broadcasters: [AccountBroadcaster] = [NotificationBroadcaster()]
    
    /// The default environment. This is used if you do not supply an environment when registering accounts
    public static let defaultEnvironment = "Test"
    
    public init(accounts: [String: Set<Account>] = [:]) {
        allAccounts = accounts
    }
}


// MARK: - Account registration, deregistration and access
extension TestAccountManager {
    /// All of the active environments. This will return an empty array if no accoutn is registered
    public var environments: [String] {
        get { return Array(self.allAccounts.keys) }
    }
    
    /// Registers an account to a given environment
    ///
    /// - Parameters:
    ///   - account: The account to register
    ///   - environment: The environment to register the account. by default "test" will be used
    public func register(account: Account, environment: String = defaultEnvironment) {
        guard var envAccounts = allAccounts[environment] else {
            allAccounts[environment] = [account]
            return
        }
        envAccounts.insert(account)
    }
    
    
    /// Attempts to deregister an account for a given environment. If no account is found nothing is done.
    ///
    /// - Parameters:
    ///   - account: The account to deregister
    ///   - environment: The environment the account is for
    public func deregister(account: Account, environment: String = defaultEnvironment) {
        guard var setOfAccounts = allAccounts[environment] else {
            return
        }
        
        setOfAccounts.remove(account)
        
        // clean up and remove the empty array if we are out of elements
        if(setOfAccounts.isEmpty) {
            allAccounts[environment] = nil
        }
    }
    
    
    /// Optionally returns an array of accounts for a given environment. If no environemnt or no accounts in an environment are found, nil is returned.
    ///
    /// - Parameter environment: The environment to check
    /// - Returns: A Set of accounts for an environment, or nil
    public func accounts(environment: String = defaultEnvironment) -> Set<Account>? {
        guard let envAccounts = self.allAccounts[environment] else {
            return nil
        }
        return envAccounts
    }
}

// MARK: - Account selection and broadcasting
extension TestAccountManager {
    
    /// Adds a new broadcaster that will be alerted when an account is selected. Please see AccountBroadcaster for details
    ///
    /// - Parameter broadcaster: The broadcaster to be added
    public func add(broadcaster: AccountBroadcaster) {
        self.broadcasters.append(broadcaster)
    }
    
    
    /// Select an account. The account must be already registered for the given environment or nothing will be done. This will initiate a message to all broadcaster of what account was selected. Call this from your UI if you allow the selection of an account from a table view.
    ///
    /// - Parameters:
    ///   - account: The account was selected.
    ///   - environment: The environment the account belongs to.
    public func select(account: Account, environment: String = defaultEnvironment) {
        guard let accounts = self.accounts(environment: environment) else {
            return
        }
        guard accounts.contains(account) else {
            return
        }
        for broadcaster in self.broadcasters {
            broadcaster.selected(account: account, environment: environment)
        }
    }
}
