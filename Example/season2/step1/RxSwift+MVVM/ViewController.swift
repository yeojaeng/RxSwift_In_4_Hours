//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
                self?.view.layoutIfNeeded()
            })
    }

    // Observable's LifeCycle
    // 1. Create -> 2. Subscribe -> 3. onNext -> 4. onCompleted || onError -> 5. Disposed

    // 비동기적으로 생성되는 데이터를 return
    private func downloadJSON(_ url: String) -> Observable<String?> {
        return Observable.create() { emitter in
            let url = URL(string: url)!

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }

                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }

            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(self.activityIndicator, true)

        // Observable로 오는 데이터를 받아서 처리하는 방법
        downloadJSON(MEMBER_LIST_URL)
            .observeOn(MainScheduler.instance) // UI Thread로 전환
        .subscribe(onNext: { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        })
            .disposed(by: disposeBag)
    }
}
