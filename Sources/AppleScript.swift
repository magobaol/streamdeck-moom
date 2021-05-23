//
//  AppleScript.swift
//  Plugin
//
//  Created by Jarno Le Conté on 27/10/2019.
//  Copyright © 2019 Jarno Le Conté. All rights reserved.
//

import Foundation

func scriptForGettingMoomProfiles() -> String {
    return """
    tell application "Moom"
        set moomProfiles to list of snapshots
    end tell
    
    return moomProfiles
    """
}

func scriptForActivateMoomProfile(moomProfile: String) -> String {
    return """
    tell application "Moom" to arrange windows according to snapshot named "\(moomProfile)"
    """
}

func executeAppleScript(source: String) -> NSAppleEventDescriptor? {
    var error: NSDictionary?
    let script = NSAppleScript.init(source: source);
    let result = script?.executeAndReturnError(&error)
    
    if (error != nil) {
        NSLog("AppleScript ERROR");
        return nil;
    }
    
    return result;
}

extension NSAppleEventDescriptor {
  func toStringArray() -> [String] {
    guard let listDescriptor = self.coerce(toDescriptorType: typeAEList) else {
      return []
    }
    return (0..<listDescriptor.numberOfItems)
      .compactMap { listDescriptor.atIndex($0 + 1)?.stringValue }
  }
}
