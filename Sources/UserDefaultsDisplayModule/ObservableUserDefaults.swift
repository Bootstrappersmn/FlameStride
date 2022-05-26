//
//  ObservableUserDefaults.swift
//  
//
//  Created by Jeremy Bannister on 5/4/22.
//

///
import Foundation
import Combine

///
public actor ObservableUserDefaults: ObservableObject {
    
    // MARK: - object_change_publishers
    
    ///
    public let objectWillChange = ObservableObjectPublisher()
    
    
    
    // MARK: - userDefaults
    
    ///
    public let userDefaults: UserDefaults
    
    
    
    // MARK: - latestPublishedKeys
    
    ///
    @MainActor
    public private(set) var latestPublishedKeys: Set<String> = [] {
        willSet { objectWillChange.send() }
    }
    
    
    
    // MARK: - init
    
    ///
    public convenience init (userDefaults: UserDefaults) {
        
        ///
        self.init(_userDefaults: userDefaults)
        
        ///
        Task { [weak self] in await self?.launch() }
    }
    
    ///
    private init (_userDefaults: UserDefaults) {
        
        ///
        self.userDefaults = _userDefaults
    }
}

///
private extension ObservableUserDefaults {
    
    ///
    func launch () async {
        
        ///
        Task { [weak self] in await self?.update() }
    }
    
    ///
    @MainActor
    func update () {
        
        ///
        let newKeys = Set(userDefaults.dictionaryRepresentation().keys)
        
        ///
        if newKeys != latestPublishedKeys {
            
            ///
            latestPublishedKeys = newKeys
        }
        
        ///
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 100_000_000)
            self?.update()
        }
    }
}
