//
//  Plugin.swift
//  A plug-in for Stream Deck
//
//  Created by Jarno Le Conté on 19/10/2019.
//  Copyright © 2019 Jarno Le Conté. All rights reserved.
//

import Foundation

public class Plugin: NSObject, ESDEventsProtocol {
    
    private func getMoomProfiles() -> Array<String> {
        return executeAppleScript(source: scriptForGettingMoomProfiles())?
            .toStringArray() ?? [String]()
    }
    
    private func sendMoomProfilesToPropertyInspector(withContext context: Any) {
        let moomProfiles = getMoomProfiles();
        let data = ["moomProfiles": moomProfiles];
        
        connectionManager?.send(toPropertyInspector: data, forContext: context)
    }
    
    var connectionManager: ESDConnectionManager?;
    var knownContexts: [Any] = [];
    
    public func setConnectionManager(_ connectionManager: ESDConnectionManager) {
        self.connectionManager = connectionManager;
    }
    
    public func keyDown(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Nothing to do
    }
    
    public func keyUp(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        let settings = payload["settings"] as? [AnyHashable : Any];
        if let moomProfile = settings?["profile"] as? String, moomProfile != "" {
            let scriptResult = executeAppleScript(source: scriptForActivateMoomProfile(moomProfile: moomProfile))?
                .toStringArray()
            if (scriptResult == nil) {
                connectionManager?.showAlert(forContext: context)
            }
        } else {
            connectionManager?.showAlert(forContext: context)
        }
    }
    
    public func sendToPlugin(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        
        let msg = payload["msg"] as? String;
        if (msg == "refreshprofilelist") {
            sendMoomProfilesToPropertyInspector(withContext: context)
        }
    }

    public func willAppear(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Add the context to the list of known contexts
        knownContexts.append(context);
    }
    
    public func willDisappear(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Remove the context from the list of known contexts
        knownContexts.removeAll { isEqualContext($0, context) }
    }

    public func propertyInspectorDidAppear(forAction action: String, withContext context: Any, withPayload payload: [AnyHashable : Any], forDevice deviceID: String) {
        // Add the context to the list of known contexts
        knownContexts.append(context);
        sendMoomProfilesToPropertyInspector(withContext: context)
    }
    

    public func deviceDidConnect(_ deviceID: String, withDeviceInfo deviceInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
    
    public func deviceDidDisconnect(_ deviceID: String) {
        // Nothing to do
    }
    
    public func applicationDidLaunch(_ applicationInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
    
    public func applicationDidTerminate(_ applicationInfo: [AnyHashable : Any]) {
        // Nothing to do
    }
}

