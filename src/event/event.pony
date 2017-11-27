use "collections"
use "buffered"
use "../keyboard"

class SDL2StructEvent
    var array : Array[U8 val] val

    new create() =>
        let array' : Array[U8 val] iso = recover iso Array[U8 val]() end
        for i in Range(0, 56) do
            array'.push(0)
        end
        array = recover val consume array' end

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

primitive QuitEvent

type SDL2Event is (KeyBoardEvent | QuitEvent | None)

