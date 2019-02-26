/*:
 [Previous: Custom Animation Class](@previous)
 
 The customization of music is very simple. What you need to do is just add mp3 files and set their file names.
 */

//: - Note: Set the background music by calling `set(backgroundMusic: _)` function.
set(backgroundMusic: /*#-editable-code file name*/"file name"/*#-end-editable-code*/)
//: - Note: Set sound effects (for example, drum sound) by calling `set(audioFiles: _)` function.
set(audioFiles: [/*#-editable-code file name*/"file name"/*#-end-editable-code*/])
//: - Note: If you wanna get a better result, you can specify the time interval between two sound effects. The default value of `interval` is 0.2132
set(audioFiles: [/*#-editable-code file name*/"file name"/*#-end-editable-code*/], interval: /*#-editable-code time interval*/0.2/*#-end-editable-code*/)

//: - Experiment: Add and set your audio.

start()

/*:
 Then it is over. It's that simple.
 
 [Next: What Next?](@next)
 */
