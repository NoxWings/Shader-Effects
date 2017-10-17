using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShaderAnimation : MonoBehaviour {

	[SerializeField]
	private Shader animableShader = null;
	[SerializeField]
	private string animatedProperty = "";
	[SerializeField]
	private AnimationCurve curve = null;


	public float durationTime = 2f;

	private Renderer rend = null;
	private List<Shader> savedShaders = null;

	// Use this for initialization
	void Start() {
		this.rend = this.GetComponent<Renderer>();
		this._SaveShaders();
	}

	public void Update() {
		if (Input.GetKeyDown(KeyCode.Space)) {
			Play(durationTime, -1);
		}
	}

	public void Play(float duration, int loops = 1) {
		_RestoreShaders();
		StartCoroutine(PlayCoroutine(duration, loops));
	}

	private IEnumerator PlayCoroutine(float duration, int loops) {

		for (int counter = 0; counter != loops; counter++) {
			duration = durationTime;

			if (duration == 0) {
				Debug.LogWarning("Animation duration cannot be 0");
				break;
			}

			// Set the initial state
			_ReplaceShaders();
			_SetMaterialProperty(animatedProperty, curve.Evaluate(0.0f));
			yield return null;

			// Set the animation state
			float playStart = Time.time;

			while (playStart + duration >= Time.time) {
				// Calculate the percentage of animation passed
				float animationPercentage = (Time.time - playStart) / duration;

				// Calculate the animation value of the curve
				float animationValue = curve.Evaluate(animationPercentage);

				// Set the property on every material shader
				_SetMaterialProperty(animatedProperty, animationValue);
		
				yield return null;
			}

			// Set the last state
			_SetMaterialProperty(animatedProperty, curve.Evaluate(1.0f));
			yield return null;
		}
	}

	private void _SetMaterialProperty(string propertyName, float value) {
		// Update material property
		foreach (Material mat in rend.materials) {
			if (mat.HasProperty(propertyName)) {
				mat.SetFloat(propertyName, value);
			} else {
				Debug.Log("Material "+mat.name+" doesn't have a property named "+propertyName);
			}
		}
	}
	
	private void _SaveShaders() {
		this.savedShaders = new List<Shader>();
		foreach (Material mat in rend.materials) {
			savedShaders.Add(mat.shader);
		}
	}

	private void _ReplaceShaders() {
		if (animableShader == null) {
			Debug.LogError("You need to place an animable shader in the script");
			return;
		}

		foreach (Material mat in rend.materials) {
			mat.shader = animableShader;
		}
	}

	private void _RestoreShaders() {
		IEnumerator<Shader> shaderEnum = savedShaders.GetEnumerator();
		foreach (Material mat in rend.materials) {
			if (shaderEnum.MoveNext()) mat.shader = shaderEnum.Current;
		}
	}
}
