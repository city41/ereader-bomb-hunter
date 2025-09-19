# Repeated input

The input module should provide

- input_pressed: a bitmask of all currently pressed buttons for that frame
- input_just_pressed: a bitmask of all buttons that just became pressed this frame
- input_repeat_pressed: a bitmask of buttons that have been held down and fire at repeated intervals to allow repeating actions that aren't forced to happen each frame as they would with input_just_pressed

## input_repeat_pressed

should set the bit to 1 if the input was just pressed that frame. Then set it back to zero until the cooldown period has been reached. If the button is let go, reset the cooldown.
