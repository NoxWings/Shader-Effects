using UnityEngine;
using System.Collections;

public class CameraOrbit : MonoBehaviour {

	private Camera cam = null;
	public Transform target = null;
	public Vector3 lookAtOffset = Vector3.zero;
	public float autoRotationRate = 20f;
	public float manualRotationRate = 200f;
	public float zoomRate = 10;
	public bool autoRotate = true;

	void Start () {
		cam = this.GetComponent<Camera>();
		if (cam == null) {
			Debug.LogError("There is no camera attached in this object.");
		}
	}
	
	void Update () {
		// Camera and target sanity check
		if (cam == null || target == null) return;

		// 0. Input mapping
		// zoom input
		float zoom = Input.GetAxis("Mouse ScrollWheel") 
			+ (Input.GetKey(KeyCode.KeypadPlus)?1:0) 
			+ (Input.GetKey(KeyCode.KeypadMinus)?-1:0);

		// keyboard rotation
		float horizontal = -Input.GetAxis("Horizontal") * Time.deltaTime;
		float vertical = -Input.GetAxis("Vertical") * Time.deltaTime;
		// mouse rotation
		if (Input.GetMouseButton(0)) {
			horizontal += Input.GetAxis("Mouse X") / 15;
			vertical += Input.GetAxis("Mouse Y") / 30;
		}

		// 1. Always look at our target
		_lookAtTarget();
		// 2. Rotation
		_rotateAroundTarget(horizontal, vertical);
		// 3. Zoom
		_zoomTarget(zoom);
	}

	private void _lookAtTarget() {
		cam.transform.LookAt(target.position + lookAtOffset);
	}

	private void _rotateAroundTarget(float horizontal, float vertical) {
		Vector3 point = target.position + lookAtOffset;

		// Horizontal rotation
		if (_IsNonZero(horizontal)) {
			cam.transform.RotateAround(point, Vector3.up, manualRotationRate * horizontal);
		} else if (autoRotate){
			cam.transform.RotateAround(point, Vector3.up, autoRotationRate * Time.deltaTime);
		}

		// Vertical rotation
		if (_IsNonZero(vertical)) {
			Vector3 viewDirection = (point - cam.transform.position).normalized;
			cam.transform.RotateAround(point,
			                           Vector3.Cross(viewDirection, Vector3.up),
			                           manualRotationRate * vertical);
		}
	}

	private void _zoomTarget(float zoom) {
		if (_IsNonZero(zoom)) {
			// Calculate the new camera position
			Vector3 displacement = cam.transform.forward * zoom * zoomRate * Time.deltaTime;
			Vector3 newPosition = cam.transform.position + displacement;
			// Move only if the camera will be further away from the target than a given value
			float distance = Vector3.Distance(target.position + lookAtOffset, newPosition);
			if ( distance > 0.5 ) cam.transform.position = newPosition;
		}
	}

	static bool _IsNonZero(float axisValue) {
		return (axisValue > float.Epsilon || axisValue < -float.Epsilon);
	}
}
