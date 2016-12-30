/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Extension to allow creating a CallKit CXStartCallAction from an NSUserActivity which the app was launched with
*/

import Foundation
import Intents

extension NSUserActivity: StartCallConvertible {

    var startCallHandle: String? {
        if #available(iOS 10.0, *) {
            guard
                let interaction = interaction,
                let startCallIntent = interaction.intent as? SupportedStartCallIntent,
                let contact = startCallIntent.contacts?.first
                else {
                    return nil
            }
            
            return contact.personHandle?.value
        } else {
            // TODO: Fallback on earlier versions
            return nil
        }
    }

    var video: Bool? {
        if #available(iOS 10.0, *) {
            guard
                let interaction = interaction,
                let startCallIntent = interaction.intent as? SupportedStartCallIntent
                else {
                    return nil
            }
            
            return startCallIntent is INStartVideoCallIntent
        } else {
            // TODO: Fallback on earlier versions
            return nil
        }
    }
}

protocol SupportedStartCallIntent {
    @available(iOS 10.0, *)
    var contacts: [INPerson]? { get }
}

@available(iOS 10.0, *)
extension INStartAudioCallIntent: SupportedStartCallIntent {}

@available(iOS 10.0, *)
extension INStartVideoCallIntent: SupportedStartCallIntent {}
