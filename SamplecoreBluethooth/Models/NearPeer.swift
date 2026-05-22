//
//  NearPeer.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import MultipeerConnectivity

enum PeerConnectionState {
    case discovered
    case connecting
    case connected
    case disconnected

    var displayText: String {
        switch self {
        case .discovered:   return "Discovered"
        case .connecting:   return "Connecting..."
        case .connected:    return "Connected"
        case .disconnected: return "Disconnected"
        }
    }
}

struct NearPeer: Equatable {
    let peerID: MCPeerID
    var connectionState: PeerConnectionState

    var isConnected: Bool  { connectionState == .connected  }
    var isConnecting: Bool { connectionState == .connecting }

    static func == (lhs: NearPeer, rhs: NearPeer) -> Bool {
        lhs.peerID == rhs.peerID
    }
}
