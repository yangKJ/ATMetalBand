//
//  CIImage+Ext.swift
//  Harbeth
//
//  Created by Condy on 2022/10/11.
//

import Foundation
import MetalKit

extension CIImage: C7Compatible { }

extension Queen where Base: CIImage {
    
    /// Renders a region of an image to a Metal texture.
    /// Render `bounds` of `image` to a Metal texture, optionally specifying what command buffer to use.
    /// - Parameters:
    ///   - texture: Texture type must be MTLTexture2D.
    ///   - colorSpace: Color space
    ///   - context: An evaluation context for rendering image processing results and performing image analysis.
    public func renderImageToTexture(_ texture: MTLTexture, colorSpace: CGColorSpace? = nil, context: CIContext? = nil) {
        let colorSpace = colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let ctx = context ?? {
            let options = [CIContextOption.workingColorSpace: colorSpace]
            let context: CIContext
            if #available(iOS 13.0, *) {
                context = CIContext(mtlCommandQueue: Device.commandQueue(), options: options)
            } else {
                context = CIContext(options: options)
            }
            return context
        }()
        let buffer = Device.commandQueue().makeCommandBuffer()
        // Fixed image horizontal flip problem.
        let scaledImage = base.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
            .transformed(by: CGAffineTransform(translationX: 0, y: base.extent.height))
        //let origin = CGPoint(x: -scaledImage.extent.origin.x, y: -scaledImage.extent.origin.y)
        //let bounds = CGRect(origin: origin, size: scaledImage.extent.size)
        ctx.render(scaledImage, to: texture, commandBuffer: buffer, bounds: scaledImage.extent, colorSpace: colorSpace)
        buffer?.commit()
        buffer?.waitUntilCompleted()
    }
    
    public func removingExtentOffset() -> CIImage {
        base.transformed(by: .init(translationX: -base.extent.origin.x, y: -base.extent.origin.y))
    }
}
