#import "Basic";
GetRect :: #import "GetRect";
Simp :: #import "Simp";
Window_Creation :: #import "Window_Creation";
Input :: #import "Input";

#import "tbx/engine";
#import "tbx/rectangle";
#import "tbx/ui";
#import "tbx/opengl";

#import "Hash_Table";
#import "GL";
#import "stb_image";
#import "Math";

main :: () {

    windowed_program : Windowed_Program;
    windowed_program.window_name = "Toolbox UI - Complete Widget Demo";
    init(*windowed_program);

    stbi_set_flip_vertically_on_load(1);
    font := msdf_font_load("data/fonts/pt_serif/atlas.json", "data/fonts/pt_serif/atlas.png");

    msdf_renderer: Multi_Channel_Signed_Distance_Field_Text_Renderer;
    init(*msdf_renderer);

    rect_renderer: Absolute_Position_Color_Alpha_Renderer;
    init(*rect_renderer);

    ui_context: UI_Context;
    ui_init(*ui_context, *font, *msdf_renderer, *rect_renderer);

    // startfold demo state 

    // powers the ui values

    click_count: s32 = 0;
    colored_click_count: s32 = 0;

    toggle_value := false;

    checkbox_a := false;
    checkbox_b := true;
    checkbox_c := false;

    radio_selection: s32 = 0;

    slider_float_val: float32 = 50.0;
    slider_int_val: s32 = 5;

    drag_float_val: float32 = 0.0;
    drag_int_val: s32 = 10;

    progress: float32 = 0.0;

    hp: float32 = 75.0;
    mp: float32 = 30.0;
    xp: float32 = 450.0;

    text_buf1: [256] u8;
    text_len1: s32 = 0;

    text_buf2: [256] u8;
    text_len2: s32 = 0;

    text_buf3: [256] u8;
    text_len3: s32 = 0;

    dropdown_selection: s32 = 0;
    dropdown_items :: string.["Apple", "Banana", "Cherry", "Date", "Elderberry"];

    dropdown_selection2: s32 = 0;
    dropdown_items2 :: string.["Red", "Green", "Blue", "Yellow", "Cyan", "Magenta"];

    list_selection: s32 = 0;
    list_items :: string.[
        "Alpha", "Bravo", "Charlie", "Delta",
        "Echo", "Foxtrot", "Golf", "Hotel",
        "India", "Juliet", "Kilo", "Lima"
    ];

    list_selection2: s32 = 0;
    list_items2 :: string.[
        "Warrior", "Mage", "Rogue", "Cleric",
        "Ranger", "Bard", "Paladin", "Monk"
    ];

    selectable_index: s32 = 0;

    edit_color: Vector4 = .{0.8, 0.2, 0.3, 1.0};
    edit_color2: Vector4 = .{0.1, 0.5, 0.9, 1.0};

    tab_selection: s32 = 0;
    tab_names :: string.["General", "Graphics", "Audio", "Controls"];

    tab_selection2: s32 = 0;
    tab_names2 :: string.["Inventory", "Skills", "Quests"];

    show_main_demo     := false;
    show_layout_demo   := false;
    show_advanced_demo := false;
    show_style_demo    := false;
    show_debug         := false;

    layout_checkbox1 := true;
    layout_checkbox2 := false;
    layout_slider1: float32 = 25.0;
    layout_slider2: float32 = 75.0;

    style_slider: float32 = 50.0;
    style_checkbox := false;

    scroll_selection: s32 = 0;

    disabled_checkbox := true;

    last_time := seconds_since_init();

    // endfold demo state 

    while !windowed_program.end_program {
        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);
            if it.window == windowed_program.window {
                windowed_program.window_width  = it.width;
                windowed_program.window_height = it.height;
            }
        }

        // todo make an engine function that packs all this up so we don't have to do this.

        mouse_left_down  := false;
        mouse_right_down := false;
        scroll_y: float32 = 0;
        ctrl_held  := false;
        shift_held := false;

        for event: Input.events_this_frame {
            if event.type == .QUIT {
                windowed_program.end_program = true;
            }

            if event.type == .KEYBOARD {
                if event.key_pressed {
                    if event.key_code == {
                        case .BACKSPACE;   ui_push_key(.BACKSPACE);
                        case .DELETE;      ui_push_key(.DELETE);
                        case .ARROW_LEFT;  ui_push_key(.LEFT);
                        case .ARROW_RIGHT; ui_push_key(.RIGHT);
                        case .HOME;        ui_push_key(.HOME);
                        case .END;         ui_push_key(.END);
                        case .ENTER;       ui_push_key(.ENTER);
                        case .ESCAPE;      ui_push_key(.ESCAPE);
                        case .TAB;         ui_push_key(.TAB);
                    }
                }

                ctrl_held  = event.ctrl_pressed;
                shift_held = event.shift_pressed;
            }

            if event.type == .TEXT_INPUT {
                if event.utf32 >= 32 && event.utf32 < 127 {
                    ui_push_char(cast(u8) event.utf32);
                }
            }

            if event.type == {
                case .MOUSE_WHEEL;
                    if event.wheel_delta > 0 {
                        scroll_y += 1.0;
                    } else if event.wheel_delta < 0 {
                        scroll_y -= 1.0;
                    }
            }

            GetRect.getrect_handle_event(event);
        }

        if Input.input_button_states[Input.Key_Code.MOUSE_BUTTON_LEFT] & .DOWN {
            mouse_left_down = true;
        }
        if Input.input_button_states[Input.Key_Code.MOUSE_BUTTON_RIGHT] & .DOWN {
            mouse_right_down = true;
        }

        mx, my, mouse_ok := Window_Creation.get_mouse_pointer_position(windowed_program.window, false);
        mouse_x := cast(float32) mx;
        mouse_y := cast(float32) my;

        ui_set_modifiers(ctrl_held, shift_held);

        now := seconds_since_init();
        dt := now - last_time;
        last_time = now;

        glClearColor(0.10, 0.10, 0.12, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        defer Simp.swap_buffers(windowed_program.window);

        w := cast(float32) windowed_program.window_width;
        h := cast(float32) windowed_program.window_height;

        progress += cast(float32) dt * 8.0;
        if progress > 100  progress = 0;

        ui_begin_frame(mouse_x, mouse_y, mouse_left_down, mouse_right_down, scroll_y, w, h, dt);

        // startfold topbar

        ui_label("Toolbox Widget Reference");
        ui_separator();
        ui_label("Toggle demo windows below. Right-click title bar to collapse. Drag to move. Resize from bottom-right corner.");
        ui_spacing(4);

        ui_begin_row();
        if ui_button("Main Widgets")    show_main_demo     = !show_main_demo;
        if ui_button("Layout Demo")     show_layout_demo   = !show_layout_demo;
        if ui_button("Advanced")        show_advanced_demo  = !show_advanced_demo;
        if ui_button("Style Demo")      show_style_demo     = !show_style_demo;
        if ui_button("Debug Info")      show_debug          = !show_debug;
        ui_end_row();

        ui_spacing(4);

        // endfold topbar

        // startfold main widgets
        if show_main_demo {
            if ui_begin_window("Main Widgets Demo", 10, 120, 440, 620) {

                if ui_collapsing_header("ui_label  /  ui_label_colored  /  ui_label_disabled") {
                    ui_label("ui_label(\"Hello, World!\")");
                    ui_label("This is a basic text label.");

                    ui_spacing(4);
                    ui_label("ui_label_colored(text, color):");
                    ui_label_colored("Colored label - red", .{1.0, 0.2, 0.2, 1.0});
                    ui_label_colored("Colored label - green", .{0.2, 1.0, 0.3, 1.0});
                    ui_label_colored("Colored label - cyan", .{0.2, 0.8, 1.0, 1.0});

                    ui_spacing(4);
                    ui_label("ui_label_disabled(text):");
                    ui_label_disabled("This label appears disabled / dimmed.");
                }

                if ui_collapsing_header("ui_separator  /  ui_separator_text") {
                    ui_label("ui_separator() - a horizontal line:");
                    ui_separator();
                    ui_label("Content after separator.");

                    ui_spacing(4);
                    ui_label("ui_separator_text(\"Section Name\"):");
                    ui_separator_text("Named Section");
                    ui_label("Content under named separator.");
                    ui_separator_text("Another Section");
                    ui_label("More content here.");
                }

                if ui_collapsing_header("ui_spacing") {
                    ui_label("ui_spacing(pixels) - adds vertical space:");
                    ui_label("Before spacing");
                    ui_spacing(20);
                    ui_label("After 20px spacing");
                    ui_spacing(40);
                    ui_label("After 40px spacing");
                }

                if ui_collapsing_header("ui_bullet_text") {
                    ui_label("ui_bullet_text(text) - bulleted list items:");
                    ui_bullet_text("First bullet point");
                    ui_bullet_text("Second bullet point");
                    ui_bullet_text("Third bullet point");
                    ui_bullet_text("Supports any text content");
                }

                if ui_collapsing_header("ui_button  /  ui_button_colored") {
                    ui_label("ui_button(label) -> bool:");
                    if ui_button("Click Me!") click_count += 1;
                    ui_label(tprint("  Button clicked % times", click_count));

                    ui_spacing(4);
                    ui_label("Multiple buttons in a row (with ui_begin_row / ui_end_row):");
                    ui_begin_row();
                    if ui_button("A") click_count += 1;
                    if ui_button("B") click_count += 2;
                    if ui_button("C") click_count += 3;
                    if ui_button("D") click_count += 4;
                    ui_end_row();

                    ui_spacing(4);
                    ui_label("ui_button_colored(label, normal, hover, active) -> bool:");
                    ui_button_colored(
                        "Danger!",
                        .{0.70, 0.15, 0.15, 1},
                        .{0.85, 0.20, 0.20, 1},
                        .{0.50, 0.10, 0.10, 1}
                    );
                    ui_button_colored(
                        "Success",
                        .{0.15, 0.55, 0.15, 1},
                        .{0.20, 0.70, 0.20, 1},
                        .{0.10, 0.40, 0.10, 1}
                    );
                    ui_button_colored(
                        "Info",
                        .{0.15, 0.35, 0.70, 1},
                        .{0.20, 0.45, 0.85, 1},
                        .{0.10, 0.25, 0.50, 1}
                    );
                }

                if ui_collapsing_header("ui_toggle") {
                    ui_label("ui_toggle(label_on, label_off, *value) -> bool:");
                    ui_toggle("Enabled", "Disabled", *toggle_value);
                    ui_label(tprint("  Toggle state: %", ifx toggle_value then "ON" else "OFF"));
                }

                if ui_collapsing_header("ui_checkbox") {
                    ui_label("ui_checkbox(label, *value) -> bool:");
                    ui_checkbox("Enable Feature A", *checkbox_a);
                    ui_checkbox("Enable Feature B", *checkbox_b);
                    ui_checkbox("Enable Feature C", *checkbox_c);
                    ui_label(tprint("  A=%, B=%, C=%", checkbox_a, checkbox_b, checkbox_c));
                }

                if ui_collapsing_header("ui_radio") {
                    ui_label("ui_radio(label, *value, option) -> bool:");
                    ui_radio("Option 1 (Easy)", *radio_selection, 0);
                    ui_radio("Option 2 (Medium)", *radio_selection, 1);
                    ui_radio("Option 3 (Hard)", *radio_selection, 2);
                    ui_label(tprint("  Selected option: %", radio_selection));
                }

                if ui_collapsing_header("ui_slider_float  /  ui_slider_int") {
                    ui_label("ui_slider_float(label, *value, min, max) -> bool:");
                    ui_slider_float("Speed", *slider_float_val, 0, 100);
                    ui_label(tprint("  Float value: %", slider_float_val));

                    ui_spacing(4);
                    ui_label("ui_slider_int(label, *value, min, max) -> bool:");
                    ui_slider_int("Quantity", *slider_int_val, 0, 20);
                    ui_label(tprint("  Int value: %", slider_int_val));
                }

                if ui_collapsing_header("ui_drag_float  /  ui_drag_int") {
                    ui_label("ui_drag_float(label, *value, speed) -> bool:");
                    ui_label("  Click and drag horizontally to change value.");
                    ui_drag_float("Position X", *drag_float_val, 0.1);
                    ui_label(tprint("  Drag float: %", drag_float_val));

                    ui_spacing(4);
                    ui_label("ui_drag_int(label, *value, speed) -> bool:");
                    ui_drag_int("Count", *drag_int_val);
                    ui_label(tprint("  Drag int: %", drag_int_val));
                }

                if ui_collapsing_header("ui_progress_bar") {
                    ui_label("ui_progress_bar(fraction, label):");
                    ui_progress_bar(progress / 100.0);
                    ui_spacing(2);
                    ui_progress_bar(0.25, "25% - Fixed");
                    ui_spacing(2);
                    ui_progress_bar(0.60, "Loading Assets...");
                    ui_spacing(2);
                    ui_progress_bar(1.0, "Complete!");
                }

                if ui_collapsing_header("ui_stat_bar") {
                    ui_label("ui_stat_bar(label, current, max, fill_color):");
                    ui_stat_bar("HP", hp, 100, .{0.2, 0.8, 0.3, 1});
                    ui_stat_bar("MP", mp, 100, .{0.2, 0.4, 0.9, 1});
                    ui_stat_bar("XP", xp, 1000, .{0.9, 0.7, 0.1, 1});
                    ui_stat_bar("Stamina", 90, 100, .{0.9, 0.5, 0.1, 1});

                    ui_spacing(4);
                    ui_label("Adjust HP with slider:");
                    ui_slider_float("HP Value", *hp, 0, 100);
                }

                if ui_collapsing_header("ui_text_input") {
                    ui_label("ui_text_input(label, *buffer, *length) -> bool:");
                    ui_label("  Click to focus, type to enter text, Backspace to delete.");
                    ui_text_input("Name", *text_buf1, *text_len1);
                    ui_text_input("Email", *text_buf2, *text_len2);
                    ui_text_input("Notes", *text_buf3, *text_len3);

                    name_str: string;
                    name_str.data = text_buf1.data;
                    name_str.count = text_len1;
                    ui_label(tprint("  Name field: '%'", name_str));

                    email_str: string;
                    email_str.data = text_buf2.data;
                    email_str.count = text_len2;
                    ui_label(tprint("  Email field: '%'", email_str));
                }

                if ui_collapsing_header("ui_dropdown") {
                    ui_label("ui_dropdown(label, items, *selected) -> bool:");
                    ui_dropdown("Fruit", dropdown_items, *dropdown_selection);
                    ui_label(tprint("  Selected fruit: %", dropdown_items[dropdown_selection]));

                    ui_spacing(4);
                    ui_dropdown("Color", dropdown_items2, *dropdown_selection2);
                    ui_label(tprint("  Selected color: %", dropdown_items2[dropdown_selection2]));
                }

                if ui_collapsing_header("ui_list_box") {
                    ui_label("ui_list_box(label, items, *selected, visible_count) -> bool:");
                    ui_list_box("NATO Alphabet", list_items, *list_selection, 5);
                    ui_label(tprint("  Selected: %", list_items[list_selection]));

                    ui_spacing(4);
                    ui_list_box("Character Class", list_items2, *list_selection2, 4);
                    ui_label(tprint("  Selected class: %", list_items2[list_selection2]));
                }

                if ui_collapsing_header("ui_selectable") {
                    ui_label("ui_selectable(label, is_selected) -> bool:");
                    ui_label("  Click an item to select it.");
                    for i : 0..5 {
                        name := tprint("Selectable Item #%", i);
                        if ui_selectable(name, selectable_index == cast(s32) i) {
                            selectable_index = cast(s32) i;
                        }
                    }
                    ui_label(tprint("  Selected index: %", selectable_index));
                }

                if ui_collapsing_header("ui_collapsing_header (this is one!)") {
                    ui_label("ui_collapsing_header(label, default_open) -> bool:");
                    ui_label("  Click the header to expand/collapse.");
                    ui_label("  You are reading the contents of a collapsing header right now.");

                    if ui_collapsing_header("Nested Collapsing Header") {
                        ui_label("  This is nested inside another collapsing header.");
                        ui_label("  Collapsing headers can be nested arbitrarily.");
                    }
                }

                if ui_collapsing_header("ui_tree_node  /  ui_tree_pop") {
                    ui_label("ui_tree_node(label, default_open) -> bool:");
                    ui_label("  Hierarchical collapsible nodes with indentation.");
                    ui_label("  Remember to call ui_tree_pop() when tree_node returns true.");

                    if ui_tree_node("Scene Graph") {
                        ui_label("Root node content");

                        if ui_tree_node("Player") {
                            ui_label("PlayerModel.mesh");
                            ui_label("PlayerTexture.png");

                            if ui_tree_node("Weapons") {
                                ui_label("Sword.mesh");
                                ui_label("Shield.mesh");
                                ui_tree_pop();
                            }
                            ui_tree_pop();
                        }

                        if ui_tree_node("Environment") {
                            ui_label("Terrain.mesh");
                            ui_label("Skybox.hdr");

                            if ui_tree_node("Trees") {
                                ui_label("OakTree_01.mesh");
                                ui_label("OakTree_02.mesh");
                                ui_label("PineTree_01.mesh");
                                ui_tree_pop();
                            }

                            if ui_tree_node("Rocks") {
                                ui_label("Boulder_01.mesh");
                                ui_label("Pebbles.mesh");
                                ui_tree_pop();
                            }
                            ui_tree_pop();
                        }

                        if ui_tree_node("Lights") {
                            ui_label("DirectionalLight");
                            ui_label("PointLight_01");
                            ui_label("PointLight_02");
                            ui_tree_pop();
                        }

                        ui_tree_pop();
                    }
                }

                if ui_collapsing_header("ui_color_edit3  /  ui_color_display") {
                    ui_label("ui_color_edit3(label, *color) -> bool:");
                    ui_label("  Edits RGB channels with individual sliders.");
                    ui_color_edit3("Primary Color", *edit_color);

                    ui_spacing(4);
                    ui_color_edit3("Secondary Color", *edit_color2);

                    ui_spacing(4);
                    ui_label("ui_color_display(label, color):");
                    ui_label("  Shows a non-editable color swatch.");
                    ui_color_display("Read-only Color", .{1.0, 0.8, 0.0, 1.0});
                    ui_color_display("Another Color", .{0.5, 0.0, 1.0, 1.0});
                }

                if ui_collapsing_header("ui_image_placeholder") {
                    ui_label("ui_image_placeholder(label, width, height, tint):");
                    ui_label("  Placeholder rectangle for where an image would go.");
                    ui_image_placeholder("Texture Preview", 200, 120);
                    ui_spacing(4);
                    ui_image_placeholder("Icon 64x64", 64, 64, .{0.2, 0.4, 0.2, 1});
                    ui_spacing(2);
                    ui_image_placeholder("Banner", 300, 60, .{0.4, 0.2, 0.1, 1});
                }

                ui_end_window();
            }
        }

        // endfold main widgets

        // startfold layout
        if show_layout_demo {
            if ui_begin_window("Layout Demo", 460, 120, 400, 520) {

                if ui_collapsing_header("ui_begin_row  /  ui_end_row") {
                    ui_label("ui_begin_row() / ui_end_row():");
                    ui_label("  Lays out widgets horizontally in a single row.");

                    ui_begin_row();
                    ui_button("Left");
                    ui_button("Center");
                    ui_button("Right");
                    ui_end_row();

                    ui_spacing(4);
                    ui_label("Row of checkboxes:");
                    ui_begin_row();
                    ui_checkbox("X", *layout_checkbox1);
                    ui_checkbox("Y", *layout_checkbox2);
                    ui_end_row();

                    ui_spacing(4);
                    ui_label("Row of colored buttons:");
                    ui_begin_row();
                    ui_button_colored("Save", .{0.1, 0.5, 0.1, 1}, .{0.15, 0.65, 0.15, 1}, .{0.08, 0.35, 0.08, 1});
                    ui_button_colored("Load", .{0.1, 0.3, 0.6, 1}, .{0.15, 0.4, 0.75, 1}, .{0.08, 0.2, 0.45, 1});
                    ui_button_colored("Reset", .{0.6, 0.1, 0.1, 1}, .{0.75, 0.15, 0.15, 1}, .{0.45, 0.08, 0.08, 1});
                    ui_end_row();
                }

                if ui_collapsing_header("ui_indent  /  ui_unindent") {
                    ui_label("ui_indent() / ui_unindent():");
                    ui_label("  Increases/decreases the left indentation.");

                    ui_label("Level 0 - no indent");
                    ui_indent();
                    ui_label("Level 1 - indented once");
                    ui_indent();
                    ui_label("Level 2 - indented twice");
                    ui_indent();
                    ui_label("Level 3 - indented three times");
                    ui_unindent();
                    ui_label("Back to Level 2");
                    ui_unindent();
                    ui_label("Back to Level 1");
                    ui_unindent();
                    ui_label("Back to Level 0");
                }

                if ui_collapsing_header("ui_begin_panel  /  ui_end_panel") {
                    ui_label("ui_begin_panel(label, height):");
                    ui_label("  A simple background panel, no title bar or drag.");

                    ui_begin_panel("inner_panel_demo", 120);
                    ui_label("Inside a panel!");
                    ui_label("Panels are simple containers.");
                    ui_checkbox("Panel checkbox", *layout_checkbox1);
                    ui_slider_float("Panel slider", *layout_slider1, 0, 100);
                    ui_end_panel();
                }

                if ui_collapsing_header("ui_begin_scroll_region  /  ui_end_scroll_region") {
                    ui_label("ui_begin_scroll_region(label, height) -> float32:");
                    ui_label("  A scrollable region. Scroll with mouse wheel.");

                    scroll := ui_begin_scroll_region("demo_scroll_region", 150);
                    for i : 0..19 {
                        item_name := tprint("Scroll Item #%", i);
                        if ui_selectable(item_name, scroll_selection == cast(s32) i) {
                            scroll_selection = cast(s32) i;
                        }
                    }
                    ui_end_scroll_region();
                    ui_label(tprint("  Scroll selection: %", scroll_selection));
                }

                if ui_collapsing_header("ui_begin_tab_bar  /  ui_end_tab_bar") {
                    ui_label("ui_begin_tab_bar(label, *selected, names) -> s32:");
                    ui_label("  Tabbed interface. Click tabs to switch content.");

                    ui_begin_tab_bar("demo_tabs", *tab_selection, tab_names);

                    if tab_selection == 0 {
                        ui_label("General tab content.");
                        ui_checkbox("Fullscreen", *checkbox_a);
                        ui_checkbox("VSync", *checkbox_b);
                    } else if tab_selection == 1 {
                        ui_label("Graphics tab content.");
                        ui_slider_float("Brightness", *layout_slider1, 0, 100);
                        ui_slider_float("Contrast", *layout_slider2, 0, 100);
                    } else if tab_selection == 2 {
                        ui_label("Audio tab content.");
                        ui_slider_int("Master Volume", *slider_int_val, 0, 100);
                    } else if tab_selection == 3 {
                        ui_label("Controls tab content.");
                        ui_label("(Rebind controls here)");
                    }

                    ui_end_tab_bar();

                    ui_spacing(8);
                    ui_label("Another tab bar:");
                    ui_begin_tab_bar("game_tabs", *tab_selection2, tab_names2);

                    if tab_selection2 == 0 {
                        ui_label("Your inventory is empty.");
                    } else if tab_selection2 == 1 {
                        ui_label("No skills learned yet.");
                    } else if tab_selection2 == 2 {
                        ui_label("No active quests.");
                    }

                    ui_end_tab_bar();
                }

                ui_end_window();
            }
        }
        //endfold layout

        // startfold advanced
        if show_advanced_demo {
            if ui_begin_window("Advanced Widgets", 870, 120, 420, 520) {

                if ui_collapsing_header("ui_begin_table  /  ui_end_table") {
                    ui_label("ui_begin_table(label, column_count):");
                    ui_label("  Simple column-based table layout.");
                    ui_label("  ui_table_header_row, ui_table_next_row, ui_table_next_column");

                    ui_begin_table("stats_table", 3);
                    ui_table_header_row(string.["Name", "Value", "Unit"]);

                    ui_table_next_row();
                    ui_table_next_column("Speed");
                    ui_table_next_column(tprint("%.1", slider_float_val));
                    ui_table_next_column("m/s");

                    ui_table_next_row();
                    ui_table_next_column("Count");
                    ui_table_next_column(tprint("%", slider_int_val));
                    ui_table_next_column("items");

                    ui_table_next_row();
                    ui_table_next_column("Drag Float");
                    ui_table_next_column(tprint("%.2", drag_float_val));
                    ui_table_next_column("units");

                    ui_table_next_row();
                    ui_table_next_column("Drag Int");
                    ui_table_next_column(tprint("%", drag_int_val));
                    ui_table_next_column("count");

                    ui_table_next_row();
                    ui_table_next_column("HP");
                    ui_table_next_column(tprint("%", cast(s32) hp));
                    ui_table_next_column("/100");

                    ui_end_table();

                    ui_spacing(4);
                    ui_label("Another table (4 columns):");
                    ui_begin_table("inventory_table", 4);
                    ui_table_header_row(string.["Slot", "Item", "Qty", "Weight"]);

                    ui_table_next_row();
                    ui_table_next_column("1");
                    ui_table_next_column("Iron Sword");
                    ui_table_next_column("1");
                    ui_table_next_column("3.5 kg");

                    ui_table_next_row();
                    ui_table_next_column("2");
                    ui_table_next_column("Health Potion");
                    ui_table_next_column("5");
                    ui_table_next_column("0.3 kg");

                    ui_table_next_row();
                    ui_table_next_column("3");
                    ui_table_next_column("Leather Armor");
                    ui_table_next_column("1");
                    ui_table_next_column("8.0 kg");

                    ui_end_table();
                }

                if ui_collapsing_header("Deep Tree Node Example") {
                    ui_label("Demonstrating deep nesting with ui_tree_node:");

                    if ui_tree_node("File System") {
                        if ui_tree_node("C:/") {
                            if ui_tree_node("Users") {
                                if ui_tree_node("Admin") {
                                    ui_label("Desktop/");
                                    ui_label("Documents/");
                                    ui_label("Downloads/");
                                    ui_tree_pop();
                                }
                                ui_tree_pop();
                            }
                            if ui_tree_node("Program Files") {
                                ui_label("MyApp/");
                                ui_label("SomeGame/");
                                ui_tree_pop();
                            }
                            ui_tree_pop();
                        }
                        if ui_tree_node("D:/") {
                            ui_label("Backups/");
                            ui_label("Media/");
                            ui_tree_pop();
                        }
                        ui_tree_pop();
                    }
                }

                if ui_collapsing_header("Combined Interaction Example") {
                    ui_label("Widgets working together:");

                    ui_separator_text("Character Creator");

                    ui_text_input("Name", *text_buf1, *text_len1);
                    ui_dropdown("Class", list_items2, *list_selection2);
                    ui_slider_int("Level", *slider_int_val, 1, 20);

                    ui_separator_text("Attributes");
                    ui_stat_bar("Strength", cast(float32)(slider_int_val * 5), 100, .{0.9, 0.3, 0.2, 1});
                    ui_stat_bar("Intelligence", cast(float32)(slider_int_val * 4), 100, .{0.2, 0.5, 0.9, 1});
                    ui_stat_bar("Dexterity", cast(float32)(slider_int_val * 3), 100, .{0.2, 0.9, 0.3, 1});

                    ui_spacing(4);
                    char_name: string;
                    char_name.data = text_buf1.data;
                    char_name.count = text_len1;
                    if char_name.count > 0 {
                        ui_label(tprint("Character: % the % (Level %)", char_name, list_items2[list_selection2], slider_int_val));
                    } else {
                        ui_label_disabled("Enter a character name above...");
                    }
                }

                if ui_collapsing_header("ui_set_tooltip (hover buttons)") {
                    ui_label("ui_set_tooltip(text):");
                    ui_label("  Hover over the buttons below to see tooltips.");
                    ui_label("  (Tooltip shown when hot id matches)");

                    if ui_button("Hover Me 1") { }
                    if ui_button("Hover Me 2") { }
                    ui_label("  (Tooltip integration depends on checking hot state)");
                }

                if ui_collapsing_header("ui_set_window_open  /  ui_is_window_open") {
                    ui_label("ui_set_window_open(title, open):");
                    ui_label("ui_is_window_open(title) -> bool:");
                    ui_label("  Programmatically open/close windows.");

                    ui_label(tprint("  Debug window open: %", show_debug));
                    ui_label(tprint("  Style window open: %", show_style_demo));

                    ui_begin_row();
                    if ui_button("Show All Windows") {
                        show_main_demo = true;
                        show_layout_demo = true;
                        show_advanced_demo = true;
                        show_style_demo = true;
                        show_debug = true;
                    }
                    ui_end_row();
                }

                ui_end_window();
            }
        }
        
        // endfold advanced

        // startfold style
        if show_style_demo {
            if ui_begin_window("Style & Theming Demo", 10, 120, 440, 340) {

                if ui_collapsing_header("ui_push_style_float  /  ui_pop_style_float") {
                    ui_label("ui_push_style_float(variable, value):");
                    ui_label("ui_pop_style_float(variable):");
                    ui_label("  Temporarily change style variables.");

                    ui_label("Normal font size label.");

                    ui_push_style_float(.FONT_SIZE, 24.0);
                    ui_label("Large font (24px)!");
                    ui_pop_style_float(.FONT_SIZE);

                    ui_push_style_float(.FONT_SIZE, 10.0);
                    ui_label("Small font (10px)!");
                    ui_pop_style_float(.FONT_SIZE);

                    ui_label("Back to normal font size.");

                    ui_spacing(4);
                    ui_label("Changing padding:");
                    ui_push_style_float(.PADDING, 20.0);
                    ui_button("Big Padding Button");
                    ui_pop_style_float(.PADDING);

                    ui_push_style_float(.PADDING, 2.0);
                    ui_button("Tiny Padding Button");
                    ui_pop_style_float(.PADDING);

                    ui_spacing(4);
                    ui_label("Changing button height:");
                    ui_push_style_float(.BUTTON_HEIGHT, 40.0);
                    ui_button("Tall Button");
                    ui_pop_style_float(.BUTTON_HEIGHT);

                    ui_push_style_float(.BUTTON_HEIGHT, 18.0);
                    ui_button("Short Button");
                    ui_pop_style_float(.BUTTON_HEIGHT);
                }

                if ui_collapsing_header("ui_push_style_color  /  ui_pop_style_color") {
                    ui_label("ui_push_style_color(variable, value):");
                    ui_label("ui_pop_style_color(variable):");

                    ui_label("Normal text and accent colors.");

                    ui_push_style_color(.TEXT, .{1.0, 1.0, 0.0, 1.0});
                    ui_label("Yellow text via style push!");
                    ui_pop_style_color(.TEXT);

                    ui_push_style_color(.ACCENT, .{1.0, 0.0, 1.0, 1.0});
                    ui_checkbox("Magenta accent checkbox", *style_checkbox);
                    ui_slider_float("Magenta slider", *style_slider, 0, 100);
                    ui_pop_style_color(.ACCENT);

                    ui_push_style_color(.BG, .{0.3, 0.1, 0.1, 1.0});
                    ui_push_style_color(.BORDER, .{1.0, 0.3, 0.3, 1.0});
                    ui_button("Red themed button");
                    ui_pop_style_color(.BORDER);
                    ui_pop_style_color(.BG);
                }

                if ui_collapsing_header("ui_begin_disabled  /  ui_end_disabled") {
                    ui_label("ui_begin_disabled() / ui_end_disabled():");
                    ui_label("  Makes text appear dimmed (disabled style).");

                    ui_label("This is enabled.");

                    ui_begin_disabled();
                    ui_label("This label is disabled.");
                    ui_checkbox("Disabled checkbox", *disabled_checkbox);
                    ui_button("Disabled-looking button");
                    ui_end_disabled();

                    ui_label("This is enabled again.");
                }

                ui_end_window();
            }
        }

        // endfold style

        // startfold debug
        if show_debug {
            if ui_begin_window("Debug Info", 460, 120, 300, 220) {

                ui_label("ui_debug_overlay():");
                ui_label("  Shows internal UI state for debugging.");
                ui_separator();
                ui_debug_overlay();

                ui_end_window();
            }
        }
        // endfold debug

        ui_end_frame();

        sleep_milliseconds(10);
        reset_temporary_storage();
    }

    ui_destroy(*ui_context);
    msdf_font_destroy(*font);
}
