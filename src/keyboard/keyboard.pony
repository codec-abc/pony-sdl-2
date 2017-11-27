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