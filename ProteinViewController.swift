//
//  ProteinViewController.swift
//  protein
//
//  Created by kudakwashe on 2019/11/13.
//  Copyright © 2019 WeThinkCode. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class ProteinViewController: UIViewController, SCNSceneRendererDelegate {
    
    var ligandName: String?
    
     var atoms: [atomdata] = []
        var atomconnect: [atomlinkdata] = []
        var conections: [String] = []
        
        func makeSphere(_ Atoms: atomdata, _ colour: UIColor) -> SCNNode {
            
            let boxGeo = SCNSphere(radius: 0.40)
            

            boxGeo.firstMaterial?.diffuse.contents = colour

            let box = SCNNode(geometry: boxGeo)
            box.position = SCNVector3Make(Atoms.atomX!, Atoms.atomY!, Atoms.atomZ!)
            return box
        }
        
        func lineBetweenNodeA(_ Atoms: [atomdata]) -> SCNNode {

            
            let startPos = SCNVector3(x: Atoms[0].atomX!, y: Atoms[0].atomY!, z: Atoms[0].atomZ!)
            let endPos = SCNVector3(x: Atoms[1].atomX!, y: Atoms[1].atomY!, z: Atoms[1].atomZ!)
            let height = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(startPos), SCNVector3ToGLKVector3(endPos)))

            let cylinderGeometry = SCNCylinder(radius: 0.1, height: height)
            cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.gray
            let cylinderNode = SCNNode(geometry: cylinderGeometry)
            cylinderNode.position.y = Float(height/2)
            let xAxisNode = SCNNode()
            xAxisNode.eulerAngles.x = Float(-Double.pi / 2)
            xAxisNode.addChildNode(cylinderNode)
            let startNode = SCNNode()
            let endNode = SCNNode()
            startNode.position = startPos
            endNode.position = endPos
            startNode.addChildNode(xAxisNode)
            startNode.constraints = [SCNLookAtConstraint(target: endNode)]
            let final = SCNNode()
            final.addChildNode(startNode)
            return startNode

        }
        
        
        
        
        func justget(){
            let url_tokens = "https://files.rcsb.org/ligands/view/"+ligandName!+"_model.pdb"
                let url_k = NSURL(string: url_tokens)!
                let request = NSMutableURLRequest(url: url_k as URL)
                let task = URLSession.shared.dataTask(with: request as URLRequest)
                {
                    (data, response, error) in
                    let lastString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    guard let value = lastString else {return}
    //                let fullName    = "First Last"
                    let fullNameArr = value.components(separatedBy: "\n")
                    var splitline: [String] = []
                    var holdlinksA: String = ""
                    var holdlinksB: String = ""
                    for run in fullNameArr{
                        splitline = run.components(separatedBy: " ").filter { $0 != "" }
    //                    print(splitline)
                        if (splitline.count == 12 && splitline[0] == "ATOM"){
                            self.atoms.append(atomdata(atomid: splitline[1] , atomX: Float(splitline[6]), atomY: Float(splitline[7]), atomZ: Float(splitline[8]), atomtype: splitline[11]))
    //                        print("X: " + splitline[6] + " Y:" + splitline[7] + " Z :" + splitline[8] + " type:" + splitline[11])
                        }else if (splitline.count >= 3  && splitline[0] == "CONECT"){

                            for index in 2...(-1 + splitline.count){
                                holdlinksA = splitline[1] + "," + splitline[index]
                                holdlinksB = splitline[index] + "," + splitline[1]
                                if self.conections.firstIndex(of: holdlinksA) == nil
                                    && self.conections.firstIndex(of: holdlinksB) == nil {
                                    self.conections.append(holdlinksA)
                                }
                            }
                        }
 
                    }
                    DispatchQueue.main.async {
                        self.GenerateView()
                    }
    //                self.GenerateView()
    //                print(self.atoms)
                }
                task.resume()

            }
        
        func getLinkedAtoms(_ connects: String) -> [atomdata]{
    //        print(connects)
            let links = connects.components(separatedBy: ",")
            return [self.atoms[-1 + Int(links[0])!], self.atoms[-1 + Int(links[1])!]]
        }
        
        func GenerateView(){

            let scene = SCNScene()
            let colour = GetColours()
            
            for index in 0...(-1 + self.atoms.count) {
                scene.rootNode.addChildNode(makeSphere(self.atoms[index], colour.GetColour(self.atoms[index].atomtype)))
    //            scene.rootNode.addChildNode(lineBetweenNodeA(self.atoms[-1 + index], self.atoms[index]))
             }
            for index in self.conections {
    //                    scene.rootNode.addChildNode(makeSphere(self.atoms[index], colour.GetColour(self.atoms[index].atomtype)))
                scene.rootNode.addChildNode(lineBetweenNodeA(getLinkedAtoms(index)))
             }
            

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            
    //        scene.rootNode.addChildNode(cameraNode)
            cameraNode.position = SCNVector3(x: 10, y: 0, z: 00)
            

            let scnView = self.view as! SCNView
            
            scnView.delegate = self
            
            scnView.autoenablesDefaultLighting = true

            scnView.scene = scene
            

            scnView.allowsCameraControl = true
            
            scnView.backgroundColor = UIColor.white
                    

        }
    
    @objc func shareid(){
        print("hi khutjo")
        let scnView = self.view as! SCNView
        
        let newImg: UIImage = scnView.snapshot()

    }
        
        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .white
            navigationController?.navigationBar.prefersLargeTitles = true
//            let Share = UIBarButtonItem()
//            Share.title = "Share"
//            Share.action = @selector(shareid())
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareid))
//            self.navigationItem.rightBarButtonItem = Share
            navigationItem.title = ligandName?.uppercased()
            justget()
       }
        
    //    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    //        //Makes the lines thicker
    //        glLineWidth(100)
    //    }

    override func loadView() {
          let scnView = SCNView(frame: UIScreen.main.bounds, options: nil)
          self.view = scnView
        }
        override var shouldAutorotate: Bool {
            return true
        }
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return .allButUpsideDown
            } else {
                return .all
            }
        }
}
