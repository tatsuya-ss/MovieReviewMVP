//
//  GradientView.swift
//  MovieReviewMVP
//
//  Created by 坂本龍哉 on 2021/08/30.
//

import UIKit

@IBDesignable
final class GradientView: UIView {

    @IBInspectable var Color1: UIColor = UIColor.orange
    @IBInspectable var Color2: UIColor = UIColor.red

    @IBInspectable var Position1: CGPoint = CGPoint.init(x: 0.5, y: 0)
    @IBInspectable var Position2: CGPoint = CGPoint.init(x: 0.5, y: 1)

    // 実際の描画
    override func draw(_ rect: CGRect) {
        // グラデーションレイヤーを用意
        let gradientLayer = CAGradientLayer()
        // gradientLayerのサイズを指定
        gradientLayer.frame = self.bounds

        // グラデーションさせる色の指定
        let color1 = Color1.cgColor
        let color2 = Color2.cgColor

        // CAGradientLayerに色を設定（ここでたくさん色を指定することも可能？）
        gradientLayer.colors = [color1, color2]

        // グラデーションの開始点、終了点を設定（0~1）
        gradientLayer.startPoint = Position1
        gradientLayer.endPoint = Position2

        // ViewControllerの親Viewレイヤーにレイヤーを挿入する
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

}
