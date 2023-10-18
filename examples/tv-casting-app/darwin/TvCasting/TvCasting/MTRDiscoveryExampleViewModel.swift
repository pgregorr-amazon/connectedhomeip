/**
 *
 *    Copyright (c) 2020-2023 Project CHIP Authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import Foundation
import os.log

class MTRDiscoveryExampleViewModel: ObservableObject {
    let Log = Logger(subsystem: "com.matter.casting",
                     category: "MTRDiscoveryExampleViewModel")
    
    @Published var displayedCastingPlayers: [MTRCastingPlayer] = []
    
    @Published var discoveryRequestStatus: Bool?;
    
    func startDiscovery() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAddDiscoveredCastingPlayers), name: NSNotification.Name.didAddCastingPlayers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRemoveDiscoveredCastingPlayers), name: NSNotification.Name.didRemoveCastingPlayers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateDiscoveredCastingPlayers), name: NSNotification.Name.didUpdateCastingPlayers, object: nil)

        MTRCastingPlayerDiscovery.sharedInstance().start()
        self.discoveryRequestStatus = true
    }
    
    @objc
    func didAddDiscoveredCastingPlayers(notification: Notification)
    {
        guard let userInfo = notification.userInfo,
              let castingPlayers     = userInfo[castingPlayersUserInfo] as? [MTRCastingPlayer] else {
              print("No MTRCastingPlayer found in notification")
              return
            }
        displayedCastingPlayers.append(contentsOf: castingPlayers)
    }
    
    @objc
    func didRemoveDiscoveredCastingPlayers(notification: Notification)
    {
        guard let userInfo = notification.userInfo,
              let castingPlayers     = userInfo[castingPlayersUserInfo] as? [MTRCastingPlayer] else {
            print("No MTRCastingPlayer found in notification")
            return
        }
        displayedCastingPlayers = displayedCastingPlayers.filter { !castingPlayers.contains($0)}
    }
    
    @objc
    func didUpdateDiscoveredCastingPlayers(notification: Notification)
    {
        guard let userInfo = notification.userInfo,
              let castingPlayers     = userInfo[castingPlayersUserInfo] as? [MTRCastingPlayer] else {
            print("No MTRCastingPlayer found in notification")
            return
        }
        for castingPlayer in castingPlayers
        {
            if let index = displayedCastingPlayers.firstIndex(where: { castingPlayer.identifier == $0.identifier })
            {
                displayedCastingPlayers[index] = castingPlayer
            }
        }
    }
}
