//
//  ViewController.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

struct ImageViewModel: Hashable {
    var largeSquare: String
    var large: String
}

enum Section {
    case main
}

class ViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageViewModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ImageViewModel>
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        
        hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupCollectionView() {
        
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
            
            let url = URL(string: imageModel.largeSquare)!
            ImageServiceClient.shared.fetchImage(withUrl: url) { (image, error) in
                cell.mainImageView.image = image
            }
                                    
            return cell
        })
    }
    
    func loadImages(forTag tag: String) {
        
        ImageServiceClient.shared.fetchImageInfoForTag(tag, page: 1) { (result, error) in
            
            //            print(result?.imagesInfo)
            guard let imageInfos = result?.imagesInfo else { return }
            
            var viewModels = [ImageViewModel]()
            
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                ImageServiceClient.shared.fetchImageSizeInfoForId(imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult {
                    
                        viewModels.append(ImageViewModel(largeSquare: sizeInfos.urlStringForType(ImageSize.LargeSquare),
                                                         large: sizeInfos.urlStringForType(ImageSize.Large)))
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                self.applySnapshot(images: viewModels)
            }
        }
    }

    private func applySnapshot(images: [ImageViewModel]) {
        
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
        
        // Do something after tapping cell
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text?.lowercased() {
            
            loadImages(forTag: searchText)
        }
        
        searchBar.resignFirstResponder()
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
