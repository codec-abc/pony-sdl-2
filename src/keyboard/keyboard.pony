use "../event"
use "buffered"

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

primitive KeyBoardEventHandler
        fun to_keyboard_event(event : SDL2StructEvent, event_type : U32) : KeyBoardEvent ? =>
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
                key_information' = _extract_key_information(event, event_type)?
            )
        else
            error
        end
    
    fun _extract_key_information(event: SDL2StructEvent, event_type : U32) : KeyInformation ? =>
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