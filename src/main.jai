#import "Basic";
#import "GetRect";
#import "Simp";
#import "Window_Creation";

#import "tbx_engine";
#import "rectangle";

main :: () {

    windowed_program : Windowed_Program;
    windowed_program.window_name = "mwe_ui";
    init(*windowed_program);

    while !windowed_program.end_program {
        Input.update_window_events();
        for Input.get_window_resizes() {
            update_window(it.window);
            if it.window == windowed_program.window {
                windowed_program.window_width  = it.width;
                windowed_program.window_height = it.height;
            }
        }

        mouse_pressed := false;
        for event: Input.events_this_frame {
            if event.type == .QUIT then {
                windowed_program.end_program = true;
            }
            getrect_handle_event(event);
        }

        // background.
        clear_render_target(.35, .35, .35, 1);
        defer swap_buffers(windowed_program.window);

        per_frame_update(*windowed_program);
        render_menus(*windowed_program);

        sleep_milliseconds(10);
        reset_temporary_storage();
    }
}

