use "lib:SDL2"
use "lib:SDL2main"
use "debug"
use "time"
use "collections"
use "buffered"

// see 
// https://wiki.libsdl.org/SDL_Event#table and
// https://wiki.libsdl.org/SDL_Event#line-10 and
// https://github.com/spurious/SDL-mirror/blob/0a931e84e3739e636783dbaeaf9401e431d5cfaf/include/SDL_events.h and
// https://github.com/Rust-SDL2/rust-sdl2/blob/6e9a00a0d254c6b6e3cc0024494f84c1cc577534/sdl2-sys/src/event.rs

use @SDL_Init[I32](flags: U32)
use @SDL_CreateWindow[Pointer[_SDL2Window val] ref](title: Pointer[U8] tag, x: I32, y: I32, w: I32, h: I32, flags: U32)
use @SDL_CreateRenderer[Pointer[_SDL2Renderer val] ref](window: Pointer[_SDL2Window val] box, index: I32, flags: U32)
use @SDL_DestroyRenderer[None](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_DestroyWindow[None](window: Pointer[_SDL2Window val] box)
use @SDL_RenderClear[I32](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_RenderPresent[None](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_SetRenderDrawColor[I32](renderer: Pointer[_SDL2Renderer val] box, r: U8, g: U8, b: U8, a: U8)
use @SDL_RenderFillRect[I32](renderer: Pointer[_SDL2Renderer val] box, rect: MaybePointer[_SDL2Rect ref] box)
use @SDL_PollEvent[I32](event : Pointer[U8] tag)

struct ref _SDL2Rect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0

    new create(x1: I32, y1: I32, w1: I32, h1: I32) =>
       x = x1
       y = y1
       w = w1
       h = h1

class SDL2StructEvent
    var array : Array[U8 val] val

    new create() =>
        let array' : Array[U8 val] iso = recover iso Array[U8 val]() end
        for i in Range(0, 56) do
            array'.push(0)
        end
        array = recover val consume array' end

primitive SDL2Flag
    fun init_video(): U32 =>0x00000020
    fun window_shown(): U32 =>  0x00000004
    fun renderer_accelerated(): U32 => 0x00000002
    fun renderer_presentvsync(): U32 => 0x00000004

primitive QuitEvent

type SDL2Event is (KeyBoardEvent | QuitEvent | None)

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

primitive KeyDown
primitive KeyUp
type KeyType is (KeyDown | KeyUp)

primitive KeyPressed
primitive KeyReleased
type KeyState is (KeyPressed | KeyReleased)

class val KeyInformation
    let scancode : U32
    let virtual_key_code : I32
    let modifiers : U16

    new val create(
        scancode' : U32,
        virtual_key_code' : I32,
        modifiers' : U16
    ) =>
        scancode = scancode'
        virtual_key_code = virtual_key_code'
        modifiers = modifiers'

class val KeyBoardEvent
    let key_type : KeyType
    let timestamp: U32
    let window_id: U32
    let key_state : KeyState
    let repeated: Bool
    let key_information : KeyInformation

    new val create(
        key_type' : KeyType,
        timestamp' : U32,
        window_id' : U32,
        key_state' : KeyState,
        repeated' : Bool,
        key_information' : KeyInformation
    ) =>
        key_type = key_type'
        timestamp = timestamp'
        window_id = window_id'
        key_state = key_state'
        repeated = repeated'
        key_information = key_information'

primitive SDL2EventTranslator

    fun _type_of_event(event : SDL2StructEvent) : U32 ? =>
        let reader = Reader
        reader.append(event.array)
        reader.peek_u32_le(where offset = 0)?
    
    fun type_of_event(event : SDL2StructEvent) : SDL2Event =>
        try
            let event_type = _type_of_event(event)?
            if 
                (event_type == SDL2EventId.key_down()) or
                (event_type == SDL2EventId.key_up()) 
            then
                try to_keyboard_event(event)? else None end
            elseif 
                event_type == SDL2EventId.quit() 
            then
                QuitEvent
            else
                None
            end
        else
            None
        end
    
    fun to_keyboard_event(event : SDL2StructEvent) : KeyBoardEvent ? =>
        let event_type =  _type_of_event(event)?
        if
            (event_type == SDL2EventId.key_down()) or
            (event_type == SDL2EventId.key_up())
        then
            let reader = Reader
            reader.append(event.array)
            KeyBoardEvent( where
                key_type' = 
                    if event_type == SDL2EventId.key_down() 
                    then 
                        KeyDown
                    else 
                        KeyUp
                    end,
                timestamp' = reader.peek_u32_le(where offset = 4)?,
                window_id' = reader.peek_u32_le(where offset = 8)?,
                key_state' = 
                    if reader.peek_u8(where offset = 12)? == 1 
                    then 
                        KeyPressed
                    else 
                        KeyReleased
                    end,
                repeated' = reader.peek_u8(where offset = 13)? != 0,
                key_information' = _extract_key_information(event)?
            )
        else
            error
        end
    
    fun _extract_key_information(event: SDL2StructEvent) : KeyInformation ? =>
        let event_type =  _type_of_event(event)?
        if
            (event_type == SDL2EventId.key_down()) or
            (event_type == SDL2EventId.key_up())
        then
            let reader = Reader
            reader.append(event.array)
            KeyInformation( where
                scancode' = reader.peek_u32_le(where offset = 16)?,
                virtual_key_code' = reader.peek_i32_le(where offset = 20)?,
                modifiers' = reader.peek_u16_le(where offset = 24)?
            )
        else
            error
        end

primitive _SDL2Window
primitive _SDL2Renderer
