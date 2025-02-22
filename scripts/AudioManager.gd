extends Node

func play_sfx(sound: AudioStream):
	if sound != null:
		var stream = AudioStreamPlayer.new()
		var random_sfx = AudioStreamRandomizer.new()
		
		random_sfx.add_stream(0, sound)
		random_sfx.random_pitch = 1.2
		
		stream.volume_db = -5.0
		stream.PROCESS_MODE_ALWAYS
		stream.stream = random_sfx
		
		self.add_child(stream)
		stream.play()
		await stream.finished
		if stream.playing == false:
			stream.queue_free()
