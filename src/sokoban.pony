use "event"
use "keyboard"
use "collections"

class Sokoban
    var _player_position : Vector2D ref = Vector2D(50, 50)
    var _speed : Vector2D ref = Vector2D(0, 0)
    var _texture : Pointer[SDL2Texture val] ref

    new create (texture : Pointer[SDL2Texture val] ref) =>
        _texture = texture
    
    new create_no_texture() =>
        _texture = Pointer[SDL2Texture val]

    fun ref tick_update(delta_time_ms : F64) =>
        if _texture.is_null() then
            return
        end
        let scale_factor : F64 = 0.001
        _player_position = 
            _player_position + 
            Vector2D(where
                x' = _speed.x * delta_time_ms * scale_factor, 
                y' = _speed.y * delta_time_ms * scale_factor
            )

    fun ref draw(renderer : Pointer[SDL2Renderer val] ref) =>
        //@SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
        for i in Range[I32](0, 6) do
            for j in Range[I32](0, 5) do
                let rect_dest = SDL2Rect(i * 128, j * 128, 128, 128)
                let rect_src = SDL2Rect(768, 256, 128, 128)
                @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
            end
        end
        let rect_dest = SDL2Rect(_player_position.x.i32(), _player_position.y.i32(), 84, 100)
        let rect_src = SDL2Rect(1091, 600, 84, 100)
        @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))

    fun ref handle_keyboard_event(kb_event : KeyBoardEvent) =>
        if not kb_event.repeated then
            let delta_speed : F64 = 
                match kb_event.key_state 
                    | KeyPressed => 1 
                    | KeyReleased => -1 
                end
            let key_code = kb_event.key_information.virtual_key_code
            if (key_code == KeyCode.virtual_key_code_up()) then
                _speed.y = _speed.y + delta_speed
            elseif (key_code == KeyCode.virtual_key_code_down()) then
                _speed.y = _speed.y - delta_speed
            elseif (key_code == KeyCode.virtual_key_code_right()) then
                _speed.x = _speed.x - delta_speed
            elseif (key_code == KeyCode.virtual_key_code_left()) then
                _speed.x = _speed.x + delta_speed
            end
        end