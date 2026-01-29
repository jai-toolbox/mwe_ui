#import "Basic";
#import "GetRect";
Input :: #import "Input";
#import "Simp";
#import "Window_Creation";

#import "rectangle";

val: s32 = 0;

Current_Menu :: enum {
    MAIN;
    GRAPHICS_SETTINGS;
    USER_SETTINGS;
    SOUND_SETTINGS;
}

current_menu := Current_Menu.MAIN;

current_theme: s32 = xx Default_Themes.Default;
my_theme: Overall_Theme;  // This gets filled out by calling the Theme_Proc for current_theme.

get_rect_normalized :: (r: Rectangle, screen_width: float, screen_height: float) -> Rect {
    return get_rect_normalized(r.x, r.y, r.w, r.h, screen_width, screen_height);
}

get_rect_normalized :: (x: float, y: float, w: float, h: float, screen_width: float, screen_height: float) -> Rect {
    r: Rect;
    
    // convert from [-1, 1] space to [0, screen_size] space
    // the center in screen coordinates:
    center_screen_x := (x + 1.0) * 0.5 * screen_width;
    center_screen_y := (y + 1.0) * 0.5 * screen_height;
    
    // convert width and height from [-1, 1] range to screen pixels
    // since w and h span from -1 to 1, a value of 2.0 would be full screen
    // so we multiply by 0.5 to get the ratio, then by screen dimensions
    screen_w := w * 0.5 * screen_width;
    screen_h := h * 0.5 * screen_height;
    
    // since rect specifies bottom-left corner, subtract half the dimensions from center
    r.x = center_screen_x - screen_w * 0.5;
    r.y = center_screen_y - screen_h * 0.5;
    r.w = screen_w;
    r.h = screen_h;
    
    return r;
}

// todo: needs to be loaded form the config file
Graphics_Settings :: struct {
    field_of_view : u32 = 90;
    max_fps : u32 = 240;
    fullscreen: bool = false;
}

graphics_settings : Graphics_Settings;
volume: u32 = 50;

main :: () {
    win := create_window(500, 500, "mwe_ui");
    window_width, window_height := get_render_dimensions(win);
    set_render_target(win);
    ui_init();
    while eventloop := true {
        Input.update_window_events();
        for Input.get_window_resizes() {
            update_window(it.window);
            if it.window == win {
                window_width    = it.width;
                window_height = it.height;
            }
        }

        mouse_pressed := false;
        for event: Input.events_this_frame {
            if event.type == .QUIT then {
                break eventloop;
            }
            getrect_handle_event(event);
        }

        apollo_current_time := current_time_consensus();
        current_time := to_float64_seconds(apollo_current_time);


        proc := default_theme_procs[current_theme];
        my_theme = proc();
        set_default_theme(my_theme);  // Just in case we don't explicitly pass themes sometimes...!

        // background.
        clear_render_target(.35, .35, .35, 1);
        defer swap_buffers(win);

        // update ui
        width, height := get_render_dimensions(win);
        ui_per_frame_update(win, width, height, current_time);

        if current_menu == {
            case .MAIN;

                label_theme := my_theme.label_theme;

                r := get_rect_normalized(create_rectangle(0, 1, 1, 0.2, .TOP_CENTER), xx width, xx height);
                label(r, "The Program", *label_theme);

                // create a button in the top left hand corner.
                k := height * 0.10;
                // r := get_rect(5.0, (xx height) - 5.0 - k, 8.5*k, k);
                r = get_rect_normalized(0, 0, 1, .125, xx width, xx height);

                center_area_rect := Rectangle.{0, 0, 1, 1};

                rectangles := subdivide_rectangle(center_area_rect, 8, .HORIZONTAL);

                rects : [..] Rect;
                defer array_free(rects);
                for rectangles array_add(*rects, get_rect_normalized(it, xx width, xx height));

                if button(rects[0], "start") {
                    // start your program here.
                }

                if button(rects[1], "graphics settings") {
                    current_menu = .GRAPHICS_SETTINGS;
                }

                if button(rects[2], "user settings") {
                    current_menu = .USER_SETTINGS;
                }
                if button(rects[3], "sound settings") {
                    current_menu = .SOUND_SETTINGS;
                }

              r = get_rect_normalized(-0.8, -.8, .2, .1, xx width, xx height);
              if button(r, "exit") break eventloop;
;

            case .GRAPHICS_SETTINGS;

                label_theme := my_theme.label_theme;
                r := get_rect_normalized(create_rectangle(0, 1, 1, 0.2, .TOP_CENTER), xx width, xx height);
                label(r, "Graphics Settings", *label_theme);

                // create a button in the top left hand corner.
                k := height * 0.10;
                r = get_rect_normalized(0, 0, 1, .125, xx width, xx height);

                resolutions :: string.["1080x1920", "720x1280", "480x640"];
                dropdown(r, resolutions , *val); // val is global

                r = get_rect_normalized(0, -.125, 1, .125, xx width, xx height);

                changed, checkbox_state := base_checkbox(r, "full screen", graphics_settings.fullscreen);
                if changed graphics_settings.fullscreen = !graphics_settings.fullscreen;

                r = get_rect_normalized(0, -.25, 1, .125, xx width, xx height);

                slider_theme := my_theme.slider_theme;
                slider(r, *graphics_settings.field_of_view, 30, 110, 1, *slider_theme, "field of view: ");

                r = get_rect_normalized(0, -.375, 1, .125, xx width, xx height);

                slider(r, *graphics_settings.max_fps, 30, 1024, 1, *slider_theme, "max fps: ");

                r = get_rect_normalized(-0.8, -.8, .2, .1, xx width, xx height);
                if button(r, "back") current_menu = .MAIN;

                r = get_rect_normalized(0.8, .8, .3, .1, xx width, xx height);
                // if button(r, "defaults") current_menu = .MAIN;

                r = get_rect_normalized(0.8, -.8, .3, .1, xx width, xx height);
                if button(r, "apply") {
                    toggle_fullscreen(win, graphics_settings.fullscreen, null);
                }

                defer draw_popups();
            case .USER_SETTINGS;
                label_theme := my_theme.label_theme;
                r := get_rect_normalized(create_rectangle(0, 1, 1, 0.2, .TOP_CENTER), xx width, xx height);
                label(r, "User Settings", *label_theme);

                r = get_rect_normalized(-0.8, -.8, .2, .1, xx width, xx height);
                if button(r, "back") current_menu = .MAIN;

            case .SOUND_SETTINGS;
                label_theme := my_theme.label_theme;
                r := get_rect_normalized(create_rectangle(0, 1, 1, 0.2, .TOP_CENTER), xx width, xx height);
                label(r, "Sound Settings", *label_theme);

                r = get_rect_normalized(-0.8, -.8, .2, .1, xx width, xx height);
                if button(r, "back") current_menu = .MAIN;

                slider_theme := my_theme.slider_theme;

                r = get_rect_normalized(0, -.375, 1, .125, xx width, xx height);
                slider(r, *volume, 0, 100, 1, *slider_theme, "volume: ");
                
        }

        sleep_milliseconds(10);
        reset_temporary_storage();
    }
}

