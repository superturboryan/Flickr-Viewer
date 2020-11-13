//
//  ViewController.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

struct Imager: Hashable {
    var image: UIImage
    var id = UUID()
}

enum Section {
    case main
}

class ViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Imager>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Imager>
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
        applySnapshot(images: self.dummyImages())
        
        hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        ImageServiceClient.shared.fetchImageInfoForTag("Cat", page: 1) { (result, error) in
            
            print(result?.imagesInfo)
        }
        
        ImageServiceClient.shared.fetchImageSizeInfoForId("50590865663") { (result, error) in
            
            print(result?.imageSizeInfos.first)
        }
    }
    
    private func configureCollectionView() {
        
        collectionView.setGridLayout(withCellsPerRow: 2,
                                     cellPadding: 10.0)
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView,
                                                 ip,
                                                 imageModel) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                                          for: ip) as! ImageCollectionViewCell
            
            cell.mainImageView.image = imageModel.image
                                    
            return cell
        })
    }

    private func applySnapshot(images: [Imager]) {
        
        snapshot = DataSourceSnapshot()
        
        snapshot.appendSections([Section.main])
        
        snapshot.appendItems(images)
        
        dataSource.apply(snapshot, animatingDifferences: true) {
            // Completion
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let imageModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        // Do something with model
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
}

extension ViewController {
    
    func dummyImages() -> [Imager] {
     
        return [Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
                Imager(image: UIImage(named: "cat")!),
                Imager(image: UIImage(named: "truck")!),
                Imager(image: UIImage(named: "catView")!),
        ]
    }
}

extension UICollectionView {
    
    func setGridLayout(withCellsPerRow cellsPerRow: CGFloat,
                       cellPadding padding: CGFloat) {
          
        let cellSize = NSCollectionLayoutDimension.absolute((self.frame.size.width - ((cellsPerRow + 1) * padding)) / cellsPerRow)
        
        self.collectionViewLayout = UICollectionViewCompositionalLayout(
            sectionProvider: { (sectionNumber, _) -> NSCollectionLayoutSection? in
                
            // Return different NSCollectionLayoutSection based on sectionNumber
                
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: cellSize,
                                                                heightDimension: cellSize))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                             heightDimension: cellSize),
                                                           subitems: [item])
            group.interItemSpacing = .fixed(padding)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = padding
            section.contentInsets = NSDirectionalEdgeInsets(top: padding,
                                                            leading: padding,
                                                            bottom: padding,
                                                            trailing: padding)
            
            return section
        })
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
