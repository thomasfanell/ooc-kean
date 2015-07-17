//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
import math
import FloatPoint3D
import FloatTransform2D
import Quaternion

FloatRotation3D: cover {
	// https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
	// Roll: Rotation about X-axis
	// Pitch: Roation about Y-axis
	// Yaw: Rotation about Z-axis
	// Here, we apply the rotations as follows: roll * pitch * yaw (which means x * y * z)
	_roll, _pitch, _yaw: Float
	_quaternion: Quaternion
	x: Float {
		get { this _roll }
		set (value) {
			this _roll = value
			this _updateQuaternion()
		}
	}
	y: Float {
		get { this _pitch }
		set (value) {
			this _pitch = value
			this _updateQuaternion()
		}
	}
	z: Float {
		get { this _yaw }
		set (value) {
			this _yaw = value
			this _updateQuaternion()
		}
	}
	init: func@ ~full(=_roll, =_pitch, =_yaw) { this _updateQuaternion() }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f) }
	init: func@ ~fromPoint(point: FloatPoint3D) { this init(point x, point y, point z) }
	createFromQuaternion: static func (quaternion: Quaternion) -> This {
		This new(quaternion rotationX, quaternion rotationY, quaternion rotationZ)
	}
	_updateQuaternion: func {
		this _quaternion = Quaternion createRotationX(this _roll) * Quaternion createRotationY(this _pitch) * Quaternion createRotationZ(this _yaw)
	}
	getTransform: func(zDistance: Float) -> FloatTransform2D {
		FloatTransform2D createXRotation(this _roll, zDistance) *
		FloatTransform2D createYRotation(this _pitch, zDistance) *
		FloatTransform2D createZRotation(this _yaw)
	}
	clamp: func ~point(floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	clamp: func ~float(floor, ceiling: Float) -> This { This new(this x clamp(floor, ceiling), this y clamp(floor, ceiling), this z clamp(floor, ceiling)) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator - -> This { This new(-this x, -this y, -this z) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator == (other: This) -> Bool { this _quaternion == other _quaternion }
	operator != (other: This) -> Bool { this _quaternion != other _quaternion }
	operator < (other: This) -> Bool { this _quaternion < other _quaternion }
	operator > (other: This) -> Bool { this _quaternion > other _quaternion }
	operator <= (other: This) -> Bool { this _quaternion <= other _quaternion }
	operator >= (other: This) -> Bool { this _quaternion >= other _quaternion }
	toString: func -> String { "%.8f" formatFloat(this x) >> ", " & "%.8f" formatFloat(this y) >> ", " & "%.8f" formatFloat(this z) }
}
operator * (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left / right x, left / right y, left / right z) }
operator - (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left - right x, left - right y, left - right z) }
