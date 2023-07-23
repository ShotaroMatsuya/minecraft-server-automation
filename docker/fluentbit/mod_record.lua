-- logged_atに時刻を入れる

function add_logged_at(tag, timestamp, record)
    -- YYYY-mm-ddTHH:MM:SSSZ形式
    -- luaのos.date関数は秒単位しか扱えないので
    -- 残りの部分はmodfで整形する
    -- またluaのos.dateは!をつけるとUTCで整形できる
    a, b = math.modf(timestamp)
    record["jst_time"] = string.format(
        "%s.%06dZ",
        os.date("%FT%T", a),
        math.floor(b * 1000 * 1000)
    )
    return 1, timestamp, record
end