//
//  ReviewDemoViewController.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/05/06.
//

import UIKit
import Cosmos

class ReviewMovieViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    private var saveButton: UIBarButtonItem!
    private var stopButton: UIBarButtonItem!
    @IBOutlet weak var reviewStarView: CosmosView!
    @IBOutlet weak var reviewTextView: UITextView!
        
    private var presenter: ReviewMoviePresenterInput!
    func inject(presenter: ReviewMoviePresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setSubView()
        setLayout()
        presenter.viewDidLoad()
        reviewTextView.delegate = self
    }
}

// MARK: - setup
private extension ReviewMovieViewController {
    func setSubView() {
        let nib =  UINib(nibName: "ReviewMovie", bundle: nil)
        if let subView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            subView.frame = self.view.bounds
            self.view.addSubview(subView)
        }
    }

    func setLayout() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = saveButton

        stopButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonTapped))
        stopButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = stopButton
        
        reviewStarView.didTouchCosmos = { review in
            self.reviewStarView.text = String(review)
        }
        reviewStarView.settings.fillMode = .half
        
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false

    }
}
// MARK: - @objc
private extension ReviewMovieViewController {
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        presenter.didTapSaveButton(reviewScore: Double(reviewStarView.text!) ?? 0.0, review: reviewTextView.text ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func stopButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension ReviewMovieViewController : UITextViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewTextView.resignFirstResponder()
    }
}

// MARK: - ReviewMoviePresenterOutput
extension ReviewMovieViewController : ReviewMoviePresenterOutput {
    
    func displayReviewMovie(_ movieInfomation: MovieInfomation) {
        fetchMovieImage(movie: movieInfomation)
    }
    
    func fetchMovieImage(movie: MovieInfomation) {
        
        guard let posperPath = movie.poster_path,
              let posterUrl = URL(string: TMDBPosterURL(posterPath: posperPath).posterURL) else { return }
        let task = URLSession.shared.dataTask(with: posterUrl) { (data, resopnse, error) in
            guard let imageData = data else { return }
            DispatchQueue.global().async { [weak self] in
                guard let image = UIImage(data: imageData) else { return }
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                    self?.backgroundImageView.image = image
                    self?.overviewTextView.text = movie.overview
                    self?.releaseDateLabel.text = movie.release_date
                }
            }
        }
        task.resume()
        
        if movie.title == nil || movie.title == "" {
            titleLabel.text = movie.original_name
        } else if movie.title != nil {
            titleLabel.text = movie.title
        } else {
            titleLabel.text = "タイトルがありません"
        }
    }
}


