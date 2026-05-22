//
//  MultipeerManager.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import UIKit
import MultipeerConnectivity

protocol MultipeerManagerDelegate: AnyObject {
    func manager(_ manager: MultipeerManager, peersDidUpdate peers: [NearPeer])
    func manager(_ manager: MultipeerManager, didLog message: String)
    func manager(_ manager: MultipeerManager, transferProgress: Float, fileName: String, isVisible: Bool)
}

final class MultipeerManager: NSObject {

    weak var delegate: MultipeerManagerDelegate?
    private(set) var peers: [NearPeer] = []
    private(set) var myPeerID: MCPeerID!

    private let serviceType = "local-share"
    private var session:    MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser:    MCNearbyServiceBrowser!
    private var progressTimers: [String: Timer] = [:]

    var connectedPeers: [NearPeer] {
        peers.filter { $0.isConnected }
    }

    func start() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()

        log("📡 Started — advertising as \"\(myPeerID.displayName)\"")
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        progressTimers.values.forEach { $0.invalidate() }
        progressTimers.removeAll()
        peers.removeAll()
    }

    func sendFile(at url: URL, to peerID: MCPeerID, completion: @escaping (Error?) -> Void) {
        let fileName = url.lastPathComponent
        log("📤 Sending \"\(fileName)\" → \(peerID.displayName)")

        let progress = session.sendResource(at: url, withName: fileName, toPeer: peerID) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error = error {
                    self.log("❌ Send failed: \(error.localizedDescription)")
                    self.delegate?.manager(self, transferProgress: 0, fileName: fileName, isVisible: false)
                } else {
                    self.log("✅ \"\(fileName)\" sent successfully")
                    self.delegate?.manager(self, transferProgress: 1.0, fileName: fileName, isVisible: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.delegate?.manager(self, transferProgress: 0, fileName: fileName, isVisible: false)
                    }
                }
                completion(error)
            }
        }

        if let p = progress {
            observeProgress(p, fileName: fileName)
        }
    }

    private func observeProgress(_ progress: Progress, fileName: String) {
        progressTimers[fileName]?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self, weak progress] t in
            guard let self, let p = progress else { t.invalidate(); return }
            let fraction = Float(p.fractionCompleted)
            DispatchQueue.main.async {
                self.delegate?.manager(self, transferProgress: fraction, fileName: fileName, isVisible: true)
            }
            if p.isFinished || p.isCancelled {
                t.invalidate()
                self.progressTimers.removeValue(forKey: fileName)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        progressTimers[fileName] = timer
    }

    private func peerIndex(for peerID: MCPeerID) -> Int? {
        peers.firstIndex { $0.peerID == peerID }
    }

    private func upsertPeer(_ peerID: MCPeerID, state: PeerConnectionState) {
        if let idx = peerIndex(for: peerID) {
            peers[idx].connectionState = state
        } else {
            peers.append(NearPeer(peerID: peerID, connectionState: state))
        }
        delegate?.manager(self, peersDidUpdate: peers)
    }

    private func removePeer(_ peerID: MCPeerID) {
        peers.removeAll { $0.peerID == peerID }
        delegate?.manager(self, peersDidUpdate: peers)
    }

    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.delegate?.manager(self, didLog: message)
        }
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        guard peerIndex(for: peerID) == nil else { return }
        upsertPeer(peerID, state: .discovered)
        log("🔍 Found: \(peerID.displayName)")

        if myPeerID.displayName <= peerID.displayName {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
            log("📨 Invitation sent → \(peerID.displayName)")
        } else {
            log("⏳ Waiting for invite from \(peerID.displayName)...")
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log("👋 Lost signal: \(peerID.displayName)")
        removePeer(peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log("❌ Browse error: \(error.localizedDescription)")
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let alreadyActive = peers.first { $0.peerID == peerID }
        if alreadyActive?.isConnected == true || alreadyActive?.isConnecting == true {
            log("⚠️ Duplicate invite from \(peerID.displayName) — ignored")
            invitationHandler(false, nil)
            return
        }
        log("📩 Invite from \(peerID.displayName) — accepting")
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log("❌ Advertise error: \(error.localizedDescription)")
    }
}

extension MultipeerManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connecting:
                self.upsertPeer(peerID, state: .connecting)
                self.log("🟡 Connecting: \(peerID.displayName)...")

            case .connected:
                self.upsertPeer(peerID, state: .connected)
                self.log("🟢 Connected: \(peerID.displayName)")

            case .notConnected:
                if let idx = self.peerIndex(for: peerID) {
                    let prev = self.peers[idx].connectionState
                    if prev == .connected || prev == .connecting {
                        self.upsertPeer(peerID, state: .disconnected)
                        self.log("🔴 Disconnected: \(peerID.displayName)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.removePeer(peerID)
                    }
                }

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let name = "received_\(Int(Date().timeIntervalSince1970)).bin"
        let url  = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url)
            log("📥 Data from \(peerID.displayName) — saved as \(name)")
        } catch {
            log("❌ Data save error: \(error.localizedDescription)")
        }
    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        log("📥 Receiving: \"\(resourceName)\" from \(peerID.displayName)")
        DispatchQueue.main.async {
            self.delegate?.manager(self, transferProgress: 0, fileName: resourceName, isVisible: true)
            self.observeProgress(progress, fileName: resourceName)
        }
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        if let error = error {
            log("❌ Receive error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.delegate?.manager(self, transferProgress: 0, fileName: resourceName, isVisible: false)
            }
            return
        }
        guard let src = localURL else { return }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(resourceName)
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: src, to: dest)
            log("✅ Received: \"\(resourceName)\" — saved to Documents")
            DispatchQueue.main.async {
                self.delegate?.manager(self, transferProgress: 1.0, fileName: resourceName, isVisible: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.delegate?.manager(self, transferProgress: 0, fileName: resourceName, isVisible: false)
                }
            }
        } catch {
            log("❌ Copy error: \(error.localizedDescription)")
        }
    }

    func session(_ session: MCSession,
                 didReceiveCertificate certificate: [Any]?,
                 fromPeer peerID: MCPeerID,
                 certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
