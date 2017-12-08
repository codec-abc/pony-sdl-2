use "event"
use "keyboard"
use "collections"

primitive Player
primitive Block
primitive BlockGoal
primitive Wall

type EntityKind is (Player | Block | BlockGoal | Wall)

class Entity
    var _entityKind: EntityKind
    var _position : Vector2D ref = Vector2D(0, 0)

    new create(kind : EntityKind, initial_position : Vector2D) =>
        _entityKind = kind
        _position = consume initial_position

    fun box get_position() : Vector2D =>
        _position.clone()
    
    fun ref set_position(new_pos : Vector2D ref) =>
        _position = consume new_pos

    fun box get_entity_kind() : EntityKind =>
        _entityKind

primitive Level1Generator
    fun apply() : List[Entity ref] ref =>
        let list : List[Entity ref] ref = List[Entity ref]
        let player = Entity(Player, Vector2D(3, 3))
        let block_1 = Entity(Block, Vector2D(5, 5))
        let block_2 = Entity(Block, Vector2D(3, 6))
        let block_goal_1 = Entity(BlockGoal, Vector2D(4, 7))
        let block_goal_2 = Entity(BlockGoal, Vector2D(9, 1))
        let wall_1 = Entity(Wall, Vector2D(8, 6))
        let wall_2 = Entity(Wall, Vector2D(9, 6))
        let wall_3 = Entity(Wall, Vector2D(9, 7))
        list.push(player)
        list.push(block_1)
        list.push(block_2)
        list.push(block_goal_1)
        list.push(block_goal_2)
        list.push(wall_1)
        list.push(wall_2)
        list.push(wall_3)
        list

class Sokoban
    var _speed : Vector2D ref = Vector2D(0, 0)
    var _texture : Pointer[SDL2Texture val] 
    var _board_size : Vector2D ref = Vector2D(10 ,10)
    var _tile_size_in_pixels : I32 = 64
    let _entities : List[Entity ref]

    new create (texture : Pointer[SDL2Texture val] ref) =>
        _entities = Level1Generator()
        _texture = texture
    
    new create_no_texture() =>
        _entities = Level1Generator()
        _texture = Pointer[SDL2Texture val]

    fun ref tick_update(delta_time_ms : F64) =>
        None

    fun ref _draw_background(renderer : Pointer[SDL2Renderer val] ref) =>
        for i in Range[I32](0, _board_size.x.i32()) do
            for j in Range[I32](0, _board_size.y.i32()) do
                let rect_dest = 
                    SDL2Rect(
                        i * _tile_size_in_pixels, 
                        j * _tile_size_in_pixels, 
                        _tile_size_in_pixels, 
                        _tile_size_in_pixels
                    )
                let rect_src = SokobanTextureCoordinates.get_ground_04()
                @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
            end
        end

    fun ref draw(renderer : Pointer[SDL2Renderer val] ref) =>
        if _texture.is_null() then
            return
        end
        _draw_background(renderer)
        
        for entity in _entities.values() do
            // TODO factorize 
            // TODO draw from Y-sorted entities
            // TODO draw from ground to above ground entity
            let kind = entity.get_entity_kind()
            match kind
                | Player =>
                    let pos = entity.get_position()
                    let rect_src = SokobanTextureCoordinates.get_player_21()
                    let rect_dest = 
                        SDL2Rect(
                            pos.x.i32() * _tile_size_in_pixels, 
                            pos.y.i32() * _tile_size_in_pixels, 
                            _tile_size_in_pixels, 
                            _tile_size_in_pixels
                        )
                    @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
                | Block =>
                    let pos = entity.get_position()
                    let rect_src = SokobanTextureCoordinates.get_crate_04()
                    let rect_dest = 
                        SDL2Rect(
                            pos.x.i32() * _tile_size_in_pixels, 
                            pos.y.i32() * _tile_size_in_pixels, 
                            _tile_size_in_pixels, 
                            _tile_size_in_pixels
                        )
                    @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
                | BlockGoal =>
                    let pos = entity.get_position()
                    let rect_src = SokobanTextureCoordinates.get_environment_06()
                    let rect_dest = 
                        SDL2Rect(
                            pos.x.i32() * _tile_size_in_pixels, 
                            pos.y.i32() * _tile_size_in_pixels, 
                            _tile_size_in_pixels, 
                            _tile_size_in_pixels
                        )
                    @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
                | Wall =>
                    let pos = entity.get_position()
                    let rect_src = SokobanTextureCoordinates.get_block_02()
                    let rect_dest = 
                        SDL2Rect(
                            pos.x.i32() * _tile_size_in_pixels, 
                            pos.y.i32() * _tile_size_in_pixels, 
                            _tile_size_in_pixels, 
                            _tile_size_in_pixels
                        )
                    @SDL_RenderCopy(renderer, _texture, MaybePointer[SDL2Rect](rect_src), MaybePointer[SDL2Rect](rect_dest))
            end
        end

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