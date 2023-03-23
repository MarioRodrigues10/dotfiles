local ipairs = ipairs
local floor = math.floor
local max = math.max
local concat = table.concat
local pango = require("utils.pango")


local humanizer = {}

local function round(value) return floor(value + 0.5) end

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function humanizer.humanize_units(units, value, from_unit)
    if not value then
        if not units.unknown_formatted then
            units.unknown_formatted = string.format("%s%s%s", units.unknown or "--", pango.thin_space, units[1].text)
        end
        return units.unknown_formatted
    end
    from_unit = from_unit or 1
    local previous_to = 1
    for i = 1, #units do
        local unit = units[i]
        if i >= from_unit and value < unit.to then
            return string.format(
                units.format or unit.format or ("%." .. tostring(units.precision or unit.precision or 0) .. "f%s%s"),
                value / previous_to,
                pango.thin_space,
                unit.text)
        end
        if unit.next ~= false then
            previous_to = unit.to
        end
    end
    return units.over or "it's over 9000!"
end

local io_speed_units = {
    { precision = 0, text = "B/s", to = 1000 },
    { precision = 0, text = "kB/s", to = 1000 * 1000 },
    { precision = 2, text = "MB/s", to = 1000 * 1000 * 1000 },
    { precision = 2, text = "GB/s", to = 1000 * 1000 * 1000 * 1000 },
    { precision = 2, text = "TB/s", to = 1000 * 1000 * 1000 * 1000 * 1000 },
}

function humanizer.io_speed(bytes, ...)
    return humanizer.humanize_units(io_speed_units, bytes, ...)
end

local file_size_units = {
    { precision = 0, text = "B", to = 1000 },
    { precision = 1, text = "kB", to = 1000 * 1000 },
    { precision = 1, text = "MB", to = 1000 * 1000 * 1000 },
    { precision = 1, text = "GB", to = 1000 * 1000 * 1000 * 1000 },
    { precision = 1, text = "TB", to = 1000 * 1000 * 1000 * 1000 * 1000 },
}

function humanizer.file_size(bytes, ...)
    return humanizer.humanize_units(file_size_units, bytes, ...)
end

do
    local days_in_year = 365.2425
    local days_in_month = days_in_year / 12
    local weeks_in_month = days_in_month / 7
    local time_parts = {
        { id = "year", count = nil, div = 60 * 60 * 24 * days_in_month * 12 },
        { id = "month", count = 12, div = 60 * 60 * 24 * days_in_month },
        { id = "week", count = weeks_in_month, div = 60 * 60 * 24 * 7, is_week = true },
        { id = "day", count = days_in_month, div = 60 * 60 * 24 },
        { id = "hour", count = 24, div = 60 * 60 },
        { id = "minute", count = 60, div = 60 },
        { id = "second", count = 60, div = 1 },
    }

    humanizer.long_time_formats = {
        year = { text = "year", plural = "years" },
        month = { text = "month", plural = "months" },
        week = { text = "week", plural = "weeks" },
        day = { text = "day", plural = "days" },
        hour = { text = "hour", plural = "hours" },
        minute = { text = "minute", plural = "minutes" },
        second = { text = "second", plural = "seconds" },
    }

    humanizer.short_time_formats = {
        year = { text = "yr" },
        month = { text = "mo" },
        week = { text = "wk" },
        day = { text = "d" },
        hour = { text = "h" },
        minute = { text = "min" },
        second = { text = "s" },
    }

    local function format_time_part(value, format, unit_separator)
        local value_text = format.format
            and string.format(format.format, value)
            or tostring(value)
        local unit_text = (value ~= 1 and format.plural)
            and format.plural
            or format.text
        return value_text .. (unit_separator or " ") .. unit_text
    end

    function humanizer.relative_time(seconds, args)
        seconds = round(max(0, seconds))
        args = args or {}

        local all_part_count = #time_parts
        local formats = args.formats or humanizer.short_time_formats
        local unit_separator = args.unit_separator or " "
        local part_separator = args.part_separator or " "
        local skip_week = args.skip_week
        local include_leading_zero = args.include_leading_zero
        local include_zero = args.include_zero ~= false
        local stop_on_zero = args.stop_on_zero ~= false

        local from_part
        local part_count
        if args.from_part then
            if type(args.from_part) == "string" then
                for i, v in ipairs(time_parts) do
                    if v.id == args.from_part then
                        from_part = i
                        break
                    end
                end
            elseif type(args.from_part) == "number" then
                from_part = args.from_part
            end
        else
            for i, v in ipairs(time_parts) do
                if formats[v.id] then
                    from_part = i
                    break
                end
            end
        end
        if args.part_count then
            part_count = args.part_count
        else
            part_count = #formats
        end
        from_part = clamp(from_part or 1, 1, all_part_count)
        part_count = clamp(part_count or 1, 1, all_part_count - from_part + 1)

        local parts = {}
        local rest = seconds
        for i = from_part, all_part_count do
            local time_part = time_parts[i]
            if not skip_week or not time_part.is_week then
                local value = rest / time_part.div
                local format = formats[time_part.id]

                value = floor(value)
                if value >= 1 then
                    rest = rest - (value * time_part.div)
                    parts[#parts + 1] = format_time_part(value, format, unit_separator)
                elseif rest == seconds then
                    if include_leading_zero then
                        parts[#parts + 1] = format_time_part(0, format, unit_separator)
                    end
                else
                    if include_zero then
                        parts[#parts + 1] = format_time_part(0, format, unit_separator)
                    elseif stop_on_zero then
                        break
                    end
                end

                if part_count > 0 and part_count == #parts then
                    break
                end
            end
        end

        if #parts == 0 then
            local time_part = time_parts[clamp(from_part + max(1, part_count), 1, all_part_count)]
            local format = formats[time_part.id]
            parts[1] = format_time_part(0, format, unit_separator)
        end

        local text = concat(parts, part_separator)

        if args.prefix then
            text = args.prefix .. text
        end
        if args.suffix then
            text = text .. args.suffix
        end

        return text
    end
end

return humanizer
