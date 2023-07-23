function add_tag(tag, timestamp, record)
    new_record = record
    new_record["tag"] = tag
    return 2, timestamp, new_record
end