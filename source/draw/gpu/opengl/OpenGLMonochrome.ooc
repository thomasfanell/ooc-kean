/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use draw-gpu
import OpenGLPacked, OpenGLCanvas, OpenGLMap, OpenGLContext
import backend/GLTexture

version(!gpuOff) {
OpenGLMonochrome: class extends OpenGLPacked {
	init: func ~fromPixels (size: IntVector2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Monochrome, size, stride, data), This channelCount, context)
		this _coordinateSystem = coordinateSystem
	}
	init: func (size: IntVector2D, context: OpenGLContext) { this init(size, size x, null, CoordinateSystem YUpward, context) }
	init: func ~fromTexture (texture: GLTexture, context: OpenGLContext) { super(texture, This channelCount, context) }
	init: func ~fromRaster (rasterImage: RasterMonochrome, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: override func -> RasterImage {
		packed := this context createBgra(IntVector2D new(this size x / 4, this size y))
		this context packToRgba(this, packed, IntBox2D new(packed size))
		buffer := packed canvas readPixels()
		result := RasterMonochrome new(buffer, this size)
		packed free()
		result
	}
	create: override func (size: IntVector2D) -> This { this context createMonochrome(size) as This }
	channelCount: static Int = 1
}
}
