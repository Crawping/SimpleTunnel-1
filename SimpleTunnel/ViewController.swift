import UIKit
import NetworkExtension

class ViewController: UIViewController ,UIGestureRecognizerDelegate{
    var vpnManager: NETunnelProviderManager = NETunnelProviderManager()
    @IBOutlet var connectButton: UIButton!
    
    // Hard code VPN configurations
    let tunnelBundleId = "ne.packet.tunnel.vpn.demo.tunnel"
    //let serverAddress = "127.0.0.1"
    let serverAddress = "192.168.3.8"
    let serverPort = "54345"
    let mtu = "1400"
    let ip = "10.8.0.2"
    let subnet = "255.255.255.0"
    let dns = "8.8.8.8,8.4.4.4"
    
    private func initVPNTunnelProviderManager() {
        NETunnelProviderManager.loadAllFromPreferences { (savedManagers: [NETunnelProviderManager]?, error: Error?) in
            if let error = error {
                print(error)
            }
            if let savedManagers = savedManagers {
                if savedManagers.count > 0 {
                    self.vpnManager = savedManagers[0]
                }
            }
            
            self.vpnManager.loadFromPreferences(completionHandler: { (error:Error?) in
                if let error = error {
                    print(error)
                }
                
                let providerProtocol = NETunnelProviderProtocol()
                providerProtocol.providerBundleIdentifier = self.tunnelBundleId
                
                providerProtocol.providerConfiguration = ["port": self.serverPort,
                                                          "server": self.serverAddress,
                                                          "ip": self.ip,
                                                          "subnet": self.subnet,
                                                          "mtu": self.mtu,
                                                          "dns": self.dns
                ]
                providerProtocol.serverAddress = self.serverAddress
                self.vpnManager.protocolConfiguration = providerProtocol
                self.vpnManager.localizedDescription = "NEPacketTunnelVPNDemoConfig"
                self.vpnManager.isEnabled = true
                
                self.vpnManager.saveToPreferences(completionHandler: { (error:Error?) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Save successfully")
                    }
                })
                self.VPNStatusDidChange(nil)
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        initVPNTunnelProviderManager()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.VPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        
        //add
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.tapped(_:)))
        
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(tapGesture)
        //add end
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func VPNStatusDidChange(_ notification: Notification?) {
        print("VPN Status changed:")
        let status = self.vpnManager.connection.status
        switch status {
        case .connecting:
            print("Connecting...")
            //connectButton.setTitle("Disconnect", for: .normal)
            break
        case .connected:
            print("Connected...")
            //connectButton.setTitle("Disconnect", for: .normal)
            break
        case .disconnecting:
            print("Disconnecting...")
            break
        case .disconnected:
            print("Disconnected...")
            //connectButton.setTitle("Connect", for: .normal)
            break
        case .invalid:
            print("Invliad")
            break
        case .reasserting:
            print("Reasserting...")
            break
        }
    }
    
    //add
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
        //print("Go!")
            
        self.vpnManager.loadFromPreferences { (error:Error?) in
            if let error = error {
                print(error)
            }
            if self.vpnManager.connection.status == .disconnected {
                do {
                    print("Go!")
                    try self.vpnManager.connection.startVPNTunnel()
                } catch {
                    print(error)
                }
            } else {
                self.vpnManager.connection.stopVPNTunnel()
            }
        }
        }
    }
    //add end
    
    /*
    @IBAction func go(_ sender: UIButton, forEvent event: UIEvent) {
        print("Go!")
        
        self.vpnManager.loadFromPreferences { (error:Error?) in
            if let error = error {
                print(error)
            }
            if (sender.title(for: .normal) == "Connect") {
                do {
                    try self.vpnManager.connection.startVPNTunnel()
                } catch {
                    print(error)
                }
            } else {
                self.vpnManager.connection.stopVPNTunnel()
            }
        }
    }
 */
    
}
