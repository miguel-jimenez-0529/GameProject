//
//  ViewController.swift
//  GameProject
//
//  Created by Macbook Pro on 30/04/18.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    private var animator : UIDynamicAnimator!
    private var snapping : UISnapBehavior!
    
    var seed = "music practice connect rhythm iron anchor dish solve tone mistake desk almost"
    lazy var seenWords = Set<String>()
    lazy var words = seed.components(separatedBy: " ")
    var currentItem = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: view)
        createNextOption()
    }
    
    func createNextOption() {
        guard seenWords.count != words.count else {
            print("Finished")
            return
        }
        //ConfigureLabel
        let itemSize = view.frame.width / 3 - 20
        let newFrame = CGRect(x: view.frame.width / 2  - (itemSize / 2)  , y: view.frame.height - itemSize, width: itemSize, height: itemSize)
        let label = UILabel(frame: newFrame)
        label.textAlignment = .center
        label.backgroundColor = UIColor.cyan
        label.layer.cornerRadius = itemSize / 2
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        
        //Add next value
        var word = ""
        var srand = -1
        repeat {
            srand = Int(arc4random_uniform(UInt32(words.count)))
            word = words[srand]
        } while seenWords.contains(word)
        
        currentItem = srand
        label.text = word
        seenWords.insert(word)
        view.addSubview(label)
        
        //Add gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.paned(gesture:)))
        label.addGestureRecognizer(panGesture)
        
        snapping = UISnapBehavior(item: label, snapTo: label.center)
        animator.addBehavior(snapping)
        
        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            label.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func paned(gesture : UIPanGestureRecognizer) {
        if let label = gesture.view as? UILabel{
            let translation = gesture.translation(in: view)
            switch gesture.state {
            case .began:
                animator.removeBehavior(snapping)
            case .changed:
                label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
            case .ended:
                if  let posibleIndexPath = collectionView.indexPathForItem(at: label.center),
                    let attributes = collectionView.layoutAttributesForItem(at: posibleIndexPath),
                    currentItem == posibleIndexPath.row {
                    animator.removeBehavior(snapping)
                    label.removeGestureRecognizer(gesture)
                    UIView.animate(withDuration:0.5, animations: {
                        label.center = attributes.center
                        label.layer.cornerRadius = 0
                        label.frame.size = attributes.bounds.size
                    }) { (finished) in
                        if finished {
                            self.createNextOption()
                        }
                    }
                }
                else {
                    animator.addBehavior(snapping)
                }
            case .failed, .cancelled:
                animator.addBehavior(snapping)
            default :
                break
            }
        }
    }
}

extension ViewController : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let label = cell.viewWithTag(1000) as? UILabel {
            label.text = words[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3 )
    }
}
