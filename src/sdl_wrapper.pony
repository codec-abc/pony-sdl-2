use "lib:SDL2"
use "lib:SDL2main"
use "debug"
use "time"
use "collections"

// see https://github.com/Rust-SDL2/rust-sdl2/blob/6e9a00a0d254c6b6e3cc0024494f84c1cc577534/sdl2-sys/src/event.rs

use @SDL_Init[I32](flags: U32)
use @SDL_CreateWindow[Pointer[_SDLWindow val] ref](title: Pointer[U8] tag, x: I32, y: I32, w: I32, h: I32, flags: U32)
use @SDL_CreateRenderer[Pointer[_SDLRenderer val] ref](window: Pointer[_SDLWindow val] box, index: I32, flags: U32)
use @SDL_DestroyRenderer[None](renderer: Pointer[_SDLRenderer val] box)
use @SDL_DestroyWindow[None](window: Pointer[_SDLWindow val] box)
use @SDL_RenderClear[I32](renderer: Pointer[_SDLRenderer val] box)
use @SDL_RenderPresent[None](renderer: Pointer[_SDLRenderer val] box)
use @SDL_SetRenderDrawColor[I32](renderer: Pointer[_SDLRenderer val] box, r: U8, g: U8, b: U8, a: U8)
use @SDL_RenderFillRect[I32](renderer: Pointer[_SDLRenderer val] box, rect: MaybePointer[_SDLRect ref] box)
use @SDL_PollEvent[I32](event : Pointer[U8] tag)

struct ref _SDLRect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0

    new create(x1: I32, y1: I32, w1: I32, h1: I32) =>
       x = x1
       y = y1
       w = w1
       h = h1

class SDLEvent
    var array : Array[U8]

    new create() =>
        array = Array[U8]()
        for i in Range(0, 56) do
            array.push(0)
        end

primitive SDL2FLAG
    fun init_video(): U32 =>0x00000020
    fun window_shown(): U32 =>  0x00000004
    fun renderer_accelerated(): U32 => 0x00000002
    fun renderer_presentvsync(): U32 => 0x00000004

primitive SDL2EventId
    fun first_event() : U32 => 0
    fun quit() : U32 => 256
    fun app_terminating() : U32 => 257
    fun app_low_memory() : U32 => 258
    fun app_will_enter_background() : U32 => 259
    fun app_did_enter_background() : U32 => 260
    fun app_will_enter_foreground() : U32 => 261
    fun app_did_enter_foreground() : U32 => 262
    fun window_event() : U32 => 512
    fun sys_wm_event() : U32 => 513
    fun key_down() : U32 => 768
    fun key_up() : U32 => 769
    fun text_editing() : U32 => 770
    fun text_input() : U32 => 771
    fun mouse_motion() : U32 => 1024
    fun mouse_button_down() : U32 => 1025
    fun mouse_button_up() : U32 => 1026
    fun mouse_wheel() : U32 => 1027
    fun joy_axis_motion() : U32 => 1536
    fun joy_ball_motion() : U32 => 1537
    fun joy_hat_motion() : U32 => 1538
    fun joy_button_down() : U32 => 1539
    fun joy_button_up() : U32 => 1540
    fun joy_device_added() : U32 => 1541
    fun joy_device_removed() : U32 => 1542
    fun controller_axis_motion() : U32 => 1616
    fun controller_button_down() : U32 => 1617
    fun controller_button_up() : U32 => 1618
    fun controller_device_added() : U32 => 1619
    fun controller_device_removed() : U32 => 1620
    fun controller_device_remapped() : U32 => 1621
    fun finger_down() : U32 => 1792
    fun finger_up() : U32 => 1793
    fun finger_motion() : U32 => 1794
    fun dollar_gesture() : U32 => 2048
    fun dollar_record() : U32 => 2049
    fun multi_gesture() : U32 => 2050
    fun clipboard_update() : U32 => 2304
    fun drop_file() : U32 => 4096
    fun user_event() : U32 => 32768
    fun last_event() : U32 => 65535

primitive SDLEventTranslator

    fun type_of_event(event : SDLEvent) : U32 =>
        try
            var byte0 : U8 = event.array(0)?
            var byte1 : U8 = event.array(1)?
            var byte2 : U8 = event.array(2)?
            var byte3 : U8 = event.array(3)?
            
            let result = 
                byte0.u32() + 
                (byte1.u32() << 8) + 
                (byte2.u32() << 16) + 
                (byte3.u32() << 24)

            result
        else
            0
        end

primitive _SDLWindow
primitive _SDLRenderer
