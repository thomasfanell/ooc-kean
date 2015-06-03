use ooc-math
use ooc-draw-gpu
import OpenGLES3Map
OpenGLES3MapPack: abstract class extends OpenGLES3Map {
	imageWidth: Int { get set }
	channels: Int { get set }
	init: func (fragmentSource: String, context: GpuContext) {
		super(This vertexSource, fragmentSource, context)
		this channels = 1
	}
	use: override func {
		super()
		this program setUniform("texture0", 0)
		offset := (2.0f / channels - 0.5f) / this imageWidth
		this program setUniform("offset", offset)
	}
	vertexSource: static String ="
		#version 300 es
		precision highp float;
		uniform highp float offset;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate;
		void main() {
			fragmentTextureCoordinate = textureCoordinate - vec2(offset, 0);
			gl_Position = vec4(vertexPosition.x, vertexPosition.y, -1, 1);
		}"
}
OpenGLES3MapPackMonochrome: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		texelOffset := 1.0f / this imageWidth
		this program setUniform("texelOffset", texelOffset)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform float texelOffset;
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			vec2 texelOffsetCoord = vec2(texelOffset, 0);
			float r = texture(texture0, fragmentTextureCoordinate).x;
			float g = texture(texture0, fragmentTextureCoordinate + texelOffsetCoord).x;
			float b = texture(texture0, fragmentTextureCoordinate + 2.0f*texelOffsetCoord).x;
			float a = texture(texture0, fragmentTextureCoordinate + 3.0f*texelOffsetCoord).x;
			outColor = vec4(r, g, b, a);
		}"
}
OpenGLES3MapPackUv: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		texelOffset := 1.0f / this imageWidth
		this program setUniform("texelOffset", texelOffset)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform float texelOffset;
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			vec2 texelOffsetCoord = vec2(texelOffset, 0);
			vec2 rg = texture(texture0, fragmentTextureCoordinate).rg;
			vec2 ba = texture(texture0, fragmentTextureCoordinate + texelOffsetCoord).rg;
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);
		}"
}
OpenGLES3MapUnpack: abstract class extends OpenGLES3Map {
	sourceSize: IntSize2D { get set }
	targetSize: IntSize2D { get set }
	init: func (fragmentSource: String, context: GpuContext) { super(This vertexSource, fragmentSource, context) }
	use: override func {
		super()
		this program setUniform("texture0", 0)
		this program setUniform("targetWidth", this targetSize width)
	}
	vertexSource: static String ="
		#version 300 es
		precision highp float;
		uniform highp float startY;
		uniform highp float scaleX;
		uniform highp float scaleY;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate;
		out vec2 originalTextureCoordinate;
		void main() {
			fragmentTextureCoordinate = vec2(scaleX * textureCoordinate.x, startY + scaleY * textureCoordinate.y);
			originalTextureCoordinate = textureCoordinate;
			gl_Position = vec4(vertexPosition.x, vertexPosition.y, -1, 1);
		}"
}
OpenGLES3MapUnpackRgbaToMonochrome: class extends OpenGLES3MapUnpack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (4 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		scaleY := targetSize height as Float / sourceSize height
		this program setUniform("scaleY", scaleY)
		this program setUniform("startY", 0.0f)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform int targetWidth;
		in highp vec2 fragmentTextureCoordinate;
		in highp vec2 originalTextureCoordinate;
		out float outColor;
		void main() {
			int pixelIndex = int(float(targetWidth) * originalTextureCoordinate.x) % 4;
			if (pixelIndex == 0)
				outColor = texture(texture0, fragmentTextureCoordinate).r;
			else if (pixelIndex == 1)
				outColor = texture(texture0, fragmentTextureCoordinate).g;
			else if (pixelIndex == 2)
				outColor = texture(texture0, fragmentTextureCoordinate).b;
			else
				outColor = texture(texture0, fragmentTextureCoordinate).a;
		}"
}
OpenGLES3MapUnpackRgbaToUv: class extends OpenGLES3MapUnpack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (2 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		startY := (sourceSize height - targetSize height) as Float / sourceSize height
		this program setUniform("startY", startY)
		scaleY := 1.0f - startY
		this program setUniform("scaleY", scaleY)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform int targetWidth;
		in highp vec2 fragmentTextureCoordinate;
		in highp vec2 originalTextureCoordinate;
		out vec2 outColor;
		void main() {
			int pixelIndex = int(float(targetWidth) * originalTextureCoordinate.x) % 2;
			vec4 texel = texture(texture0, fragmentTextureCoordinate).rgba;
			if (pixelIndex == 0)
				outColor = vec2(texel.r, texel.g);
			else
				outColor = vec2(texel.b, texel.a);
		}"
}
