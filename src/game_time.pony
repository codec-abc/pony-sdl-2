class val GameTime

    let second : I64
    let nano_second : I64

    new val create(s : I64, ns : I64) =>
        second = s
        nano_second = ns

    fun delta_s_and_ns(s : I64 val, ns : I64 val) : GameTime val^ =>
        if (ns < nano_second) then
            let r = GameTime(s - 1 - second, (ns - nano_second) + 1_000_000_000)
            r
        else
            let r = GameTime(s - second, ns - nano_second)
            r
        end
    
    fun delta(game_time : GameTime) : GameTime val^ =>
        if (game_time.nano_second < nano_second) then
            let r = GameTime(game_time.second - 1 - second, (game_time.nano_second - nano_second) + 1_000_000_000)
            r
        else
            let r = GameTime(game_time.second - second, game_time.nano_second - nano_second)
            r
        end
