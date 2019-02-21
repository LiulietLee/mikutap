/*:
 [Previous: Custom Animation Class](@previous)
 
 The customization of music is very simple. What you need to do is just add mp3 files and set their file names.
 */
//: - Note: Set the background music by calling `set(backgroundMusic: _)` function.
set(backgroundMusic: "your_background_music_file_name")
//: - Note: Set sound effects (for example, drum sound) by calling `set(audioFiles: _)` function.
set(audioFiles: ["your_sound_file_name"])
//: - Note: If you wanna get a better result, you can specify the time interval between two sound effects. The default value of `interval` is 0.2132
set(audioFiles: ["your_sound_file_name"], interval: 0.2)

//: - Experiment: Add and set your audio.

start()

/*:
 Then it is over. It's that simple.
 
 [Next: What Next?](@next)
 */
