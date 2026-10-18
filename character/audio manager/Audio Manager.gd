extends Node
class_name AudioManager
var now_play_audio: AudioStreamPlayer
@onready var audios: Array[Node] = get_children()


func randomize_pitch(audio: AudioStreamPlayer) -> void:
	audio.pitch_scale = randf_range(1.0, 1.2)

func _play_audio(audio_name: String) -> void:
	if !(audios.any(func (a): return a.name.to_lower() == audio_name.to_lower())):
		push_error("Error: No audio with name ", audio_name, " found.")
	else:
		now_play_audio = audios.filter(func (a): return a.name.to_lower() == audio_name.to_lower())[0]
		# randomize pitch
		randomize_pitch(now_play_audio)
		# play audio
		now_play_audio.play()
