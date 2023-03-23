local string = string
local math = math
local pairs = pairs
local table = table
local aplacement = require("awful.placement")
local wibox = require("wibox")
local gdebug = require("gears.debug")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local dpi = dpi
local tcolor = require("theme.color")
local capsule = require("widget.capsule")
local pango = require("utils.pango")
local css = require("utils.css")
local config = require("config")
local htable = require("helpers.table")
local hwidget = require("helpers.widget")


---------------------------------------------------------------------------------------------------

local theme = {}

theme.icon_theme = "Archdroid-Amber"

theme.useless_gap = dpi(6)


---------------------------------------------------------------------------------------------------

theme.font_name = "JetBrainsMono Nerd Font"
theme.font_size = 11

function theme.build_font(size_factor, style, name)
    return (name or theme.font_name) ..
        ", " .. (style and (style .. " ") or "") .. tostring(math.floor((size_factor or 1) * theme.font_size))
end

theme.font = theme.build_font()


---------------------------------------------------------------------------------------------------

theme.common_color_names = {
    background = "black",
    foreground = "white",
    primary    = "yellow",
    secondary  = "blue",
    urgent     = "red",
}

-- Tomorrow Night
theme.palette = {
    black   = "#1d1f21",
    white   = "#c5c8c6",
    red     = "#cc6666",
    orange  = "#de935f",
    yellow  = "#f0c674",
    green   = "#7cb36b", -- original: #b5bd68
    cyan    = "#78bab9", -- original: #8abeb7
    blue    = "#81a2be",
    magenta = "#b294bb",
    gray    = "#767876",

    black_bright   = "#3c4044",
    white_bright   = "#eaeaea",
    red_bright     = "#d54e53",
    orange_bright  = "#e78c45",
    yellow_bright  = "#e7c547",
    green_bright   = "#71c464", -- original: #b9ca4a
    cyan_bright    = "#6acdcc", -- original: #70c0b1
    blue_bright    = "#7aa6da",
    magenta_bright = "#c397d8",
    gray_bright    = "#a7aaa8",
}

theme.common = {
    background = theme.palette[theme.common_color_names.background],
    foreground = theme.palette[theme.common_color_names.foreground],
    primary    = theme.palette[theme.common_color_names.primary],
    secondary  = theme.palette[theme.common_color_names.secondary],
    urgent     = theme.palette[theme.common_color_names.urgent],

    background_bright = theme.palette[theme.common_color_names.background .. "_bright"],
    foreground_bright = theme.palette[theme.common_color_names.foreground .. "_bright"],
    primary_bright    = theme.palette[theme.common_color_names.primary .. "_bright"],
    secondary_bright  = theme.palette[theme.common_color_names.secondary .. "_bright"],
    urgent_bright     = theme.palette[theme.common_color_names.urgent .. "_bright"],
}

theme.palette_color_names = {}
for k in pairs(theme.palette) do
    if not string.match(k, "_bright$") then
        table.insert(theme.palette_color_names, k)
    end
end


---------------------------------------------------------------------------------------------------

do
    local print_generated_colors = false
    local unknown_color = "#FFFF00" -- Something bright, easy to spot

    local colors_mt = {}

    function colors_mt.__index(t, k)
        local name, value = string.match(k, "^([_%a]+)_(%d+)$")
        if not name then
            gdebug.print_warning("Unknown color '" .. k .. "'")
            rawset(t, k, unknown_color)
            return unknown_color
        end
        value = (tonumber(value) - 100) / 100
        local source_color = t[name]
        local new_color = tcolor.change(source_color, { lighten = value })
        if print_generated_colors then
            print("Generate color: ", string.format("%24s %s <- %s %s", k, new_color, source_color, name))
        end
        rawset(t, k, new_color)
        return new_color
    end

    setmetatable(theme.palette, colors_mt)
    setmetatable(theme.common, colors_mt)

    if print_generated_colors then
        for k, _ in pairs(theme.palette) do
            if not string.find(k, "_") then
                local _ = theme.palette[k .. "_66"]
            end
        end
    end
end


---------------------------------------------------------------------------------------------------

theme.bg_normal = theme.common.background
theme.fg_normal = theme.common.foreground
theme.bg_focus = theme.common.primary_66
theme.fg_focus = theme.common.foreground_bright
theme.bg_urgent = theme.common.urgent_bright
theme.fg_urgent = theme.common.foreground_bright
theme.bg_minimize = theme.common.background_bright
theme.fg_minimize = theme.common.foreground_bright
theme.bg_disabled = theme.common.background_bright
theme.fg_disabled = theme.common.foreground_50


---------------------------------------------------------------------------------------------------

theme.border_width = dpi(3)
theme.border_color_normal = theme.common.background_140
theme.border_color_active = theme.common.primary
theme.border_color_urgent = theme.common.urgent_bright
theme.border_color_marked = theme.common.secondary


---------------------------------------------------------------------------------------------------

theme.bg_systray = theme.common.background_110
theme.systray_icon_spacing = dpi(12)


---------------------------------------------------------------------------------------------------

function theme.get_progressbar_background_color(color)
    return tcolor.change(color, { alpha = 0.25 })
end

---------------------------------------------------------------------------------------------------

theme.snap_bg = "#ff0000"
theme.snapper_gap = theme.useless_gap
theme.snap_border_width = 8 -- (dpi is applied automatically)
theme.snap_shape = function(cr, width, height)
    gshape.rounded_rect(cr, width, height, dpi(16))
end


---------------------------------------------------------------------------------------------------

theme.screen_selection_border_width = dpi(1)
theme.screen_selection_color = tcolor.change(theme.common.primary, { alpha = 0.20 --[[ 0x33 ]] })


---------------------------------------------------------------------------------------------------

theme.wibar = {
    spacing = dpi(12),
    item_height = dpi(30),
    padding = {
        left = dpi(16),
        right = dpi(16),
        top = dpi(8),
        bottom = dpi(8),
    },
    build_placement = function(widget, wibar, args)
        return function(d)
            aplacement.next_to_widget(d, gtable.crush({
                geometry = hwidget.find_geometry(widget, wibar),
                position = "bottom",
                anchor = "middle",
                outside = true,
                screen = wibar.screen,
                margins = theme.popup.margins,
            }, args or {}))
        end
    end
}

theme.wibar_height = theme.wibar.item_height + theme.wibar.padding.top + theme.wibar.padding.bottom
theme.wibar_bg = theme.common.background


---------------------------------------------------------------------------------------------------

theme.capsule = {
    -- TODO: move these into `default_style`?
    item_content_spacing = dpi(8),
    item_spacing = dpi(16),
    bar_width = dpi(80),
    bar_height = dpi(12),
    shape_radius = dpi(8),
}
theme.capsule.default_style = {
    hover_overlay = tcolor.white .. "10",
    press_overlay = tcolor.white .. "10",
    background = theme.common.background_110,
    foreground = theme.common.foreground,
    border_color = theme.common.background_130,
    border_width = 0,
    shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, theme.capsule.shape_radius)
    end,
    margins = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    paddings = {
        left = dpi(14),
        right = dpi(14),
        top = dpi(6),
        bottom = dpi(6),
    },
}
theme.capsule.styles = {
    normal = {
        background = theme.capsule.default_style.background,
        foreground = theme.capsule.default_style.foreground,
        border_color = theme.capsule.default_style.border_color,
        border_width = theme.capsule.default_style.border_width,
    },
    disabled = {
        background = theme.common.background_105,
        foreground = theme.common.foreground_50,
        border_color = theme.common.background_115,
        border_width = 0,
    },
    selected = {
        background = theme.common.background_125,
        foreground = theme.common.foreground_bright,
        border_color = theme.common.background_145,
        border_width = dpi(1),
    },
    urgent = {
        background = theme.palette.red_66,
        foreground = theme.common.foreground_bright,
        border_color = theme.palette.red,
        border_width = dpi(1),
    },
}

theme.capsule.styles.palette = {}
do
    local function generate_capsule_color_style(color)
        return {
            background = theme.palette[color .. "_33"],
            foreground = theme.palette[color .. "_bright"],
            border_color = theme.palette[color .. "_66"],
            border_width = dpi(1),
        }
    end

    for _, color in pairs(theme.palette_color_names) do
        theme.capsule.styles.palette[color] = generate_capsule_color_style(color)
    end
end

theme.capsule.styles.mebox = {
    normal = {
        hover_overlay = tcolor.white .. "20",
        press_overlay = tcolor.white .. "20",
        background = tcolor.transparent,
        foreground = theme.common.foreground,
        border_color = theme.capsule.default_style.border_color,
        border_width = 0,
    },
    active = {
        hover_overlay = tcolor.white .. "20",
        press_overlay = tcolor.white .. "20",
        background = tcolor.transparent,
        foreground = theme.common.secondary_bright,
        border_color = theme.capsule.default_style.border_color,
        border_width = 0,
    },
    urgent = {
        hover_overlay = theme.common.urgent_bright .. "40",
        background = tcolor.transparent,
        foreground = theme.common.foreground,
        border_color = theme.capsule.default_style.border_color,
        border_width = 0,
    },
    normal_selected = htable.crush_clone(theme.capsule.styles.palette[theme.common_color_names.primary], { border_width = 0 }),
    active_selected = htable.crush_clone(theme.capsule.styles.palette[theme.common_color_names.secondary], { border_width = 0 }),
    urgent_selected = htable.crush_clone(theme.capsule.styles.palette.red, { border_width = 0 }),
}


---------------------------------------------------------------------------------------------------

theme.popup = {
    margins = dpi(6),
}
theme.popup.default_style = {
    bg = theme.common.background,
    fg = theme.common.foreground,
    border_color = theme.common.background_bright,
    border_width = dpi(1),
    shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(16))
    end,
    placement = aplacement.under_mouse,
    paddings = {
        left = dpi(20),
        right = dpi(20),
        top = dpi(20),
        bottom = dpi(20),
    },
}


---------------------------------------------------------------------------------------------------

theme.mebox = {
    horizontal_separator_template = {
        widget = wibox.widget.separator,
        orientation = "horizontal",
        forced_height = dpi(16),
        color = theme.common.background_bright,
        thickness = dpi(1),
        span_ratio = 1,
        update_callback = function(self, item, menu)
            self.forced_width = item.width or menu.item_width
        end,
    },
    vertical_separator_template = {
        widget = wibox.widget.separator,
        orientation = "vertical",
        forced_width = dpi(16),
        color = theme.common.background_bright,
        thickness = dpi(1),
        span_ratio = 1,
        update_callback = function(self, item, menu)
            self.forced_height = item.height or menu.item_height
        end,
    },
    header_template = {
        widget = wibox.container.margin,
        margins = {
            left = dpi(8),
            right = dpi(8),
            top = dpi(6),
            bottom = dpi(6),
        },
        {
            id = "#text",
            widget = wibox.widget.textbox,
        },
        update_callback = function(self, item)
            local text_widget = self:get_children_by_id("#text")[1]
            if text_widget then
                local color = theme.common.foreground_66
                local text = item.text or ""
                text_widget:set_markup(pango.span {
                    size = "smaller",
                    text_transform = "uppercase",
                    foreground = color,
                    weight = "bold",
                    text,
                })
            end
        end,
    },
    checkbox = {
        [false] = {
            icon = config.places.theme .. "/icons/checkbox-blank-outline.svg",
            color = theme.palette.gray,
        },
        [true] = {
            icon = config.places.theme .. "/icons/checkbox-marked.svg",
            color = theme.palette.gray_bright,
        },
    },
    radiobox = {
        [false] = {
            icon = config.places.theme .. "/icons/radiobox-blank.svg",
            color = theme.palette.gray,
        },
        [true] = {
            icon = config.places.theme .. "/icons/radiobox-marked.svg",
            color = theme.palette.gray_bright,
        },
    },
    toggle_switch = {
        [false] = {
            icon = config.places.theme .. "/icons/toggle-switch-off-outline.svg",
            color = theme.palette.gray,
        },
        [true] = {
            icon = config.places.theme .. "/icons/toggle-switch.svg",
            color = theme.palette.gray_bright,
        },
    },
}
theme.mebox.default_style = htable.crush_clone(theme.popup.default_style, {
    separator_template = theme.mebox.horizontal_separator_template,
    header_template = theme.mebox.header_template,
    placement_bounding_args = {
        honor_workarea = true,
        honor_padding = false,
        margins = theme.popup.margins,
    },
    placement = false,
    submenu_offset = dpi(4),
    active_opacity = 1,
    inactive_opacity = 1,
    paddings = {
        left = dpi(8),
        right = dpi(8),
        top = dpi(8),
        bottom = dpi(8),
    },
    item_width = dpi(128),
    item_height = dpi(36),
    item_template = {
        id = "#container",
        widget = capsule,
        margins = {
            left = 0,
            right = 0,
            top = dpi(2),
            bottom = dpi(2),
        },
        paddings = {
            left = dpi(8),
            right = dpi(8),
            top = dpi(6),
            bottom = dpi(6),
        },
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            nil,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(12),
                {
                    id = "#icon",
                    widget = wibox.widget.imagebox,
                    resize = true,
                },
                {
                    id = "#text",
                    widget = wibox.widget.textbox,
                },
            },
            {
                widget = wibox.container.margin,
                right = -dpi(4),
                {
                    visible = false,
                    id = "#submenu_icon",
                    widget = wibox.widget.imagebox,
                    resize = true,
                },
            },
        },
        update_callback = function(self, item, menu)
            self.forced_width = item.width or menu.item_width
            self.forced_height = item.height or menu.item_height

            self.enabled = item.enabled
            self.opacity = item.enabled and 1 or 0.5

            local style = item.active
                and (item.selected
                    and theme.capsule.styles.mebox.active_selected
                    or theme.capsule.styles.mebox.active)
                or (item.urgent
                    and (item.selected
                        and theme.capsule.styles.mebox.urgent_selected
                        or theme.capsule.styles.mebox.urgent)
                    or (item.selected
                        and theme.capsule.styles.mebox.normal_selected
                        or theme.capsule.styles.mebox.normal))
            self:apply_style(style)

            local icon_widget = self:get_children_by_id("#icon")[1]
            if icon_widget then
                local paddings = menu.paddings
                icon_widget.forced_width = self.forced_height - paddings.top - paddings.bottom

                local icon, color
                if item.checked == nil then
                    icon = item.icon
                    color = item.icon_color
                else
                    local checkbox_type = item.checkbox_type or "checkbox"
                    local style = theme.mebox[checkbox_type][not not item.checked]
                    icon = style.icon
                    color = style.color
                end

                if color ~= false then
                    if not color or item.active or item.selected then
                        color = style.foreground
                    end
                    local stylesheet = css.style { path = { fill = color } }
                    icon_widget:set_stylesheet(stylesheet)
                else
                    icon_widget:set_stylesheet(nil)
                end

                icon_widget:set_image(icon)
            end

            local text_widget = self:get_children_by_id("#text")[1]
            if text_widget then
                local text = item.text or ""
                text_widget:set_markup(pango.span { foreground = style.foreground, text, })
            end

            local submenu_icon_widget = self:get_children_by_id("#submenu_icon")[1]
            if submenu_icon_widget then
                submenu_icon_widget.visible = not not item.submenu
                if submenu_icon_widget.visible then
                    local icon = item.submenu_icon or config.places.theme .. "/icons/chevron-right.svg"
                    local color = style.foreground
                    local stylesheet = css.style { path = { fill = color } }
                    submenu_icon_widget:set_stylesheet(stylesheet)
                    submenu_icon_widget:set_image(icon)
                end
            end

            if item.flex then
                self.forced_width = self:fit({
                    screen = menu.screen,
                    dpi = menu.screen.dpi,
                    drawable = menu._drawable,
                }, menu.screen.geometry.width, menu.screen.geometry.height)
            end
        end,
    },
})


---------------------------------------------------------------------------------------------------

theme.bindbox = {}
theme.bindbox.default_style = htable.crush_clone(theme.popup.default_style, {
    bg = tcolor.change(theme.common.background, { alpha = 0.85 }),
    font = theme.font,
    placement = function(d)
        aplacement.centered(d, {
            honor_workarea = true,
            honor_padding = false,
        })
    end,

    page_paddings = {
        left = dpi(8),
        right = dpi(8),
        top = dpi(8),
        bottom = dpi(16),
    },
    page_width = dpi(1400),
    page_height = dpi(1000),
    page_columns = 2,

    group_spacing = dpi(16),
    item_spacing = dpi(8),

    trigger_background = theme.common.foreground,
    trigger_background_alpha = "20%",
    trigger_foreground = theme.common.foreground,

    group_background = theme.common.primary_50,
    group_foreground = theme.common.foreground_bright,
    group_ruled_background = theme.common.urgent_50,
    group_ruled_foreground = theme.common.foreground_bright,

    find_dim_background = nil,
    find_dim_foreground = theme.common.foreground_66,
    find_highlight_background = nil,
    find_highlight_foreground = theme.common.urgent_bright,

    group_path_separator_markup = pango.span { fgalpha = "50%", "  ", },
    slash_separator_markup = pango.span { fgalpha = "50%", size = "smaller", " / ", },
    plus_separator_markup = pango.span { fgalpha = "50%", "+", },
    range_separator_markup = pango.span { fgalpha = "50%", "..", },

    status_style = {
        background = theme.palette.black_50,
        foreground = theme.common.foreground,
        border_color = theme.palette.black_115,
        border_width = dpi(1),
        paddings = {
            left = dpi(16),
            right = dpi(16),
            top = dpi(12),
            bottom = dpi(12),
        },
    },
    status_spacing = dpi(24),

    find_placeholder_foreground = theme.common.foreground_66,
    find_cursor_background = theme.common.secondary_66,
    find_cursor_foreground = theme.common.foreground_bright,
})


---------------------------------------------------------------------------------------------------

theme.media_player = {}
theme.media_player.capsule = {
    normal = {
        background = theme.common.background_105,
        foreground = theme.common.foreground,
        border_width = 0,
    },
    disabled = {
        background = theme.common.background_105,
        foreground = theme.common.foreground_50,
        border_width = 0,
    },
}


---------------------------------------------------------------------------------------------------

theme.volume_osd = {
    default_style = htable.crush_clone(theme.popup.default_style, {
        bg = theme.common.background,
        fg = theme.common.foreground,
        border_color = theme.common.background_bright,
        border_width = dpi(1),
        placement = function(d)
            aplacement.top(d, {
                honor_workarea = true,
                margins = dpi(32),
            })
        end,
        paddings = {
            left = dpi(32),
            right = dpi(32),
            top = dpi(16),
            bottom = dpi(16),
        },
    }),
}
theme.volume_osd.styles = {
    normal = {
        bg = theme.volume_osd.default_style.bg,
        fg = theme.volume_osd.default_style.fg,
        border_color = theme.volume_osd.default_style.border_color,
    },
    boosted = {
        bg = theme.capsule.styles.palette.yellow.background,
        fg = theme.capsule.styles.palette.yellow.foreground,
        border_color = theme.capsule.styles.palette.yellow.border_color,
    },
    muted = {
        bg = theme.volume_osd.default_style.bg,
        fg = theme.common.foreground_50,
        border_color = theme.volume_osd.default_style.border_color,
    },
}


---------------------------------------------------------------------------------------------------

theme.tools_popup = {
    default_style = htable.crush_clone(theme.popup.default_style),
}


---------------------------------------------------------------------------------------------------

theme.calendar_popup = {
    default_style = htable.crush_clone(theme.popup.default_style),
}

do
    local function is_weekend(date)
        return date.wday == 1 or date.wday == 7
    end

    local function calendar_item_shape(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(3))
    end

    function theme.calendar_popup.default_style.embed(widget, flag, date)
        if flag == "normal" then
            widget.halign = "center"
            widget.valign = "center"
            return wibox.widget {
                widget = wibox.container.background,
                bg = is_weekend(date) and theme.common.background_127 or theme.common.background_115,
                shape = calendar_item_shape,
                widget,
            }
        elseif flag == "focus" then
            widget.halign = "center"
            widget.valign = "center"
            return wibox.widget {
                widget = wibox.container.background,
                bg = theme.common.primary_66,
                fg = theme.common.foreground_bright,
                shape = calendar_item_shape,
                widget,
            }
        elseif flag == "normal_other" then
            widget.halign = "center"
            widget.valign = "center"
            widget.markup = pango.span { color = theme.common.foreground_50, widget.text }
            return widget
        elseif flag == "focus_other" then
            widget.halign = "center"
            widget.valign = "center"
            return wibox.widget {
                widget = wibox.container.background,
                bg = theme.common.primary_50,
                fg = theme.common.foreground,
                shape = calendar_item_shape,
                widget,
            }
        elseif flag == "weeknumber" then
            widget.halign = "right"
            widget.valign = "center"
            widget.markup = pango.span { color = theme.common.foreground_50, weight = "bold", widget.text, " " }
            return wibox.widget {
                widget = wibox.container.margin,
                margins = {
                    top = dpi(6),
                    bottom = dpi(6),
                },
                widget,
            }
        elseif flag == "weekday" then
            widget.halign = "center"
            return wibox.widget {
                widget = wibox.container.margin,
                margins = {
                    left = dpi(4),
                    right = dpi(4),
                    top = dpi(2),
                    bottom = dpi(2),
                },
                widget,
            }
        elseif flag == "monthheader" or flag == "header" then
            widget.halign = "center"
            widget.markup = pango.b(widget.text)
            return wibox.widget {
                widget = wibox.container.margin,
                margins = {
                    top = dpi(6),
                    bottom = dpi(14),
                },
                widget,
            }
        elseif flag == "month" then
            return widget
        else
            return widget
        end
    end
end


---------------------------------------------------------------------------------------------------

theme.taglist_bg_occupied = theme.capsule.styles.normal.background
theme.taglist_fg_occupied = theme.capsule.styles.normal.foreground
theme.taglist_shape_border_color = theme.capsule.styles.normal.border_color
theme.taglist_shape_border_width = dpi(1)

theme.taglist_bg_focus = theme.common.primary_50
theme.taglist_fg_focus = theme.common.foreground_bright
theme.taglist_shape_border_color_focus = theme.common.primary_75
theme.taglist_shape_border_width_focus = dpi(1)

theme.taglist_bg_urgent = theme.capsule.styles.urgent.background
theme.taglist_fg_urgent = theme.capsule.styles.urgent.foreground
theme.taglist_shape_border_color_urgent = theme.capsule.styles.urgent.border_color
theme.taglist_shape_border_width_urgent = theme.capsule.styles.urgent.border_width

theme.taglist_bg_empty = theme.capsule.styles.disabled.background
theme.taglist_fg_empty = theme.capsule.styles.disabled.foreground
theme.taglist_shape_border_color_empty = theme.capsule.styles.disabled.border_color
theme.taglist_shape_border_width_empty = theme.capsule.styles.disabled.border_width

theme.taglist_bg_volatile = theme.capsule.styles.normal.background
theme.taglist_fg_volatile = theme.capsule.styles.normal.foreground
theme.taglist_shape_border_color_volatile = theme.common.secondary_75
theme.taglist_shape_border_width_volatile = dpi(1)

theme.taglist_bg_rename = theme.common.secondary_66
theme.taglist_fg_rename = theme.common.foreground_bright


---------------------------------------------------------------------------------------------------

theme.tasklist_bg_normal = theme.capsule.styles.normal.background
theme.tasklist_fg_normal = theme.capsule.styles.normal.foreground
theme.tasklist_shape_border_color = theme.capsule.styles.normal.border_color
theme.tasklist_shape_border_width = theme.capsule.styles.normal.border_width

theme.tasklist_bg_focus = theme.capsule.styles.selected.background
theme.tasklist_fg_focus = theme.capsule.styles.selected.foreground
theme.tasklist_shape_border_color_focus = theme.capsule.styles.selected.border_color
theme.tasklist_shape_border_width_focus = theme.capsule.styles.selected.border_width

theme.tasklist_bg_urgent = theme.capsule.styles.urgent.background
theme.tasklist_fg_urgent = theme.capsule.styles.urgent.foreground
theme.tasklist_shape_border_color_urgent = theme.capsule.styles.urgent.border_color
theme.tasklist_shape_border_width_urgent = theme.capsule.styles.urgent.border_width

theme.tasklist_bg_minimize = theme.capsule.styles.disabled.background
theme.tasklist_fg_minimize = theme.capsule.styles.disabled.foreground
theme.tasklist_shape_border_color_minimized = theme.capsule.styles.disabled.border_color
theme.tasklist_shape_border_width_minimized = theme.capsule.styles.disabled.border_width

theme.tasklist_plain_task_name = true
theme.tasklist_sticky = " "
theme.tasklist_ontop = " "
theme.tasklist_above = " "
theme.tasklist_below = " "
theme.tasklist_floating = " "
theme.tasklist_maximized = " "
theme.tasklist_maximized_horizontal = " "
theme.tasklist_maximized_vertical = ""
theme.tasklist_minimized = " "


---------------------------------------------------------------------------------------------------

theme.titlebar_bg_normal = theme.common.background_66
theme.titlebar_fg_normal = theme.common.foreground
theme.titlebar_bg_focus = theme.common.background
theme.titlebar_fg_focus = theme.common.foreground_bright
theme.titlebar_bg_urgent = theme.common.urgent_bright
theme.titlebar_fg_urgent = theme.common.foreground_bright

do
    local button_shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(3))
    end
    local button_paddings = {
        left = dpi(12),
        right = dpi(12),
        top = dpi(4),
        bottom = dpi(4),
    }
    local button_margins = {
        left = dpi(0),
        right = dpi(0),
        top = dpi(4),
        bottom = dpi(8),
    }
    theme.titlebar = {
        height = dpi(36),
        paddings = {
            left = dpi(12),
            right = dpi(12),
            top = dpi(0),
            bottom = dpi(0),
        },
        button = {
            opacity_normal = 0.5,
            opacity_focus = 1,
            spacing = dpi(4),
            styles = {
                normal = {
                    hover_overlay = tcolor.white .. "30",
                    press_overlay = tcolor.white .. "30",
                    background = tcolor.transparent,
                    foreground = theme.common.foreground,
                    border_width = 0,
                    shape = button_shape,
                    paddings = button_paddings,
                    margins = button_margins,
                },
                active = {
                    hover_overlay = tcolor.white .. "20",
                    press_overlay = tcolor.white .. "20",
                    background = theme.common.primary_50,
                    foreground = theme.common.foreground_bright,
                    border_color = theme.common.primary_75,
                    border_width = dpi(1),
                    shape = button_shape,
                    paddings = button_paddings,
                    margins = button_margins,
                },
                close = {
                    hover_overlay = theme.common.urgent_bright,
                    press_overlay = theme.palette.white .. "30",
                    background = tcolor.transparent,
                    foreground = theme.common.foreground_bright,
                    border_width = 0,
                    shape = button_shape,
                    paddings = button_paddings,
                    margins = button_margins,
                },
            },
            icons = {
                menu = config.places.theme .. "/icons/menu.svg",
                floating = config.places.theme .. "/icons/floating.svg",
                on_top = config.places.theme .. "/icons/arrow-to-top.svg",
                sticky = config.places.theme .. "/icons/pin.svg",
                minimize = config.places.theme .. "/icons/window-minimize.svg",
                maximize = config.places.theme .. "/icons/window-maximize.svg",
                close = config.places.theme .. "/icons/window-close.svg",
            },
        },
    }
end

do
    local toolbox_button_shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(2))
    end
    local toolbox_button_paddings = {
        left = dpi(4),
        right = dpi(4),
        top = dpi(4),
        bottom = dpi(4),
    }
    local toolbox_button_margins = {
        left = dpi(0),
        right = dpi(0),
        top = dpi(0),
        bottom = dpi(0),
    }
    theme.toolbox_titlebar = {
        height = dpi(24),
        paddings = {
            left = dpi(2),
            right = dpi(2),
            top = dpi(2),
            bottom = dpi(2),
        },
        button = {
            opacity_normal = theme.titlebar.button.opacity_normal,
            opacity_focus = theme.titlebar.button.opacity_focus,
            spacing = dpi(2),
            styles = {
                normal = {
                    hover_overlay = theme.titlebar.button.styles.normal.hover_overlay,
                    press_overlay = theme.titlebar.button.styles.normal.press_overlay,
                    background = theme.titlebar.button.styles.normal.background,
                    foreground = theme.titlebar.button.styles.normal.foreground,
                    border_width = theme.titlebar.button.styles.normal.border_width,
                    shape = toolbox_button_shape,
                    paddings = toolbox_button_paddings,
                    margins = toolbox_button_margins,
                },
                active = {
                    hover_overlay = theme.titlebar.button.styles.active.hover_overlay,
                    press_overlay = theme.titlebar.button.styles.active.press_overlay,
                    background = theme.titlebar.button.styles.active.background,
                    foreground = theme.titlebar.button.styles.active.foreground,
                    border_color = theme.titlebar.button.styles.active.border_width,
                    border_width = dpi(1),
                    shape = toolbox_button_shape,
                    paddings = toolbox_button_paddings,
                    margins = toolbox_button_margins,
                },
                close = {
                    hover_overlay = theme.titlebar.button.styles.close.hover_overlay,
                    press_overlay = theme.titlebar.button.styles.close.press_overlay,
                    background = theme.titlebar.button.styles.close.background,
                    foreground = theme.titlebar.button.styles.close.foreground,
                    border_width = theme.titlebar.button.styles.close.border_width,
                    shape = toolbox_button_shape,
                    paddings = toolbox_button_paddings,
                    margins = toolbox_button_margins,
                },
            },
            icons = theme.titlebar.button.icons,
        },
    }
end


---------------------------------------------------------------------------------------------------

function theme.build_layout_stylesheet(color)
    color = color or theme.common.foreground
    return css.style {
        [".primary"] = {
            fill = color,
        },
        [".secondary"] = {
            fill = color,
            opacity = 0.6,
        },
    }
end

theme.layout_icons = {
    tilted_right = config.places.theme .. "/layouts/tilted_right.svg",
    tilted_center = config.places.theme .. "/layouts/tilted_center.svg",
    floating = config.places.theme .. "/layouts/floating.svg",
    max = config.places.theme .. "/layouts/max.svg",
    fullscreen = config.places.theme .. "/layouts/fullscreen.svg",
}


---------------------------------------------------------------------------------------------------

theme.notification_width = dpi(400)
theme.notification_spacing = dpi(16)
theme.notification_margin = dpi(8)
theme.notification_border_width = theme.border_width
theme.notification_shape = function(cr, width, height)
    gshape.rounded_rect(cr, width, height, dpi(8))
end


---------------------------------------------------------------------------------------------------

theme.application_menu_categories = {
    utility = {
        id = "Utility",
        name = "accessories",
        icon_name = "applications-accessories",
        icon_color = theme.palette.green,
    },
    development = {
        id = "Development",
        name = "development",
        icon_name = "applications-development",
        icon_color = theme.palette.cyan,
    },
    education = {
        id = "Education",
        name = "education",
        icon_name = "applications-science",
        icon_color = theme.palette.gray,
    },
    games = {
        id = "Game",
        name = "games",
        icon_name = "applications-games",
        icon_color = theme.palette.red,
    },
    graphics = {
        id = "Graphics",
        name = "graphics",
        icon_name = "applications-graphics",
        icon_color = theme.palette.yellow,
    },
    internet = {
        id = "Network",
        name = "internet",
        icon_name = "applications-internet",
        icon_color = theme.palette.blue,
    },
    multimedia = {
        id = "AudioVideo",
        name = "multimedia",
        icon_name = "applications-multimedia",
        icon_color = theme.palette.cyan,
    },
    office = {
        id = "Office",
        name = "office",
        icon_name = "applications-office",
        icon_color = theme.palette.white,
    },
    science = {
        id = "Science",
        name = "science",
        icon_name = "applications-science",
        icon_color = theme.palette.magenta,
    },
    settings = {
        id = "Settings",
        name = "settings",
        icon_name = "applications-utilities",
        icon_color = theme.palette.orange,
    },
    tools = {
        id = "System",
        name = "system tools",
        icon_name = "applications-system",
        icon_color = theme.palette.gray,
    },
}


---------------------------------------------------------------------------------------------------

return theme
