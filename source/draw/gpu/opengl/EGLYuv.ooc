/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
use concurrent
import GraphicBuffer, OpenGLContext, OpenGLPacked
import backend/[GLTexture, EGLImage]

version(!gpuOff) {
EGLYuv: class extends OpenGLPacked {
	_handle: Pointer
	handle ::= this _handle
	init: func (buffer: GraphicBuffer, context: OpenGLContext) {
		this _handle = buffer handle
		super(EGLImage create(TextureType External, buffer size, buffer nativeBuffer, context backend), 3, context)
	}
	toRasterDefault: override func -> RasterImage { Debug error("toRasterDefault unimplemented for EGLYuv"); null }
	toRasterDefault: override func ~target (target: RasterImage) { Debug error("toRasterDefault~target unimplemented for EGLYuv") }
	draw: override func ~DrawState (drawState: DrawState) {
		// Blending is not supported for this image type, so we force it off
		drawState blendMode = BlendMode Fill
		super(drawState)
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		yuv := pen color toYuv()
		super(pointList, Pen new(ColorRgba new(yuv y, yuv u, yuv v, 255), pen width))
	}
}
}
