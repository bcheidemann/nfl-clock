color_black_rubber = "#282828";

board_width = 30.00 + 0.2;
board_height = 37.50 + 0.2;
board_depth = 1;
board_corner_radius = 5;
display_cable_cutout_width = 17.8;
display_cable_cutout_depth = 0.8;
display_cable_cutout_height = 2.0;

usbc_port_width = 8.45;
usbc_port_height = 2.66;
usbc_port_depth = 7;

// battery_dimensions = [20.5, 32, 5.3];
// battery_headroom = 0.5;
// battery_offset = [0, 0];

// battery_dimensions = [12, 28, 2.8]; // Ultra-Thin LiPo Battery LP302035 3.7V 160mAh
// battery_headroom = -2;
// battery_offset = [0, 0];

// battery_dimensions = [20, 37, 4.2]; // https://www.aliexpress.com/item/1005002418068008.html
// battery_headroom = 0;
// battery_offset = [0, 0];

// battery_dimensions = [20, 25, 3]; // https://www.aliexpress.com/item/1005002418068008.html
// battery_headroom = -1;
// battery_offset = [0, 0];

battery_dimensions = [12, 30, 3]; // https://www.aliexpress.com/item/1005005348368664.html (110mAh)
battery_headroom = -1.5;
battery_offset = [-3, 0];

button_spacing = 10.5 - 1 - 0.5;

mx1_25_battery_header_dimensions = [4.54, 4.54, 3.45];

esp32_s3_depth = mx1_25_battery_header_dimensions[2] + board_depth;

lcd_panel_depth = 1;

electronics_depth = esp32_s3_depth + 1 + battery_dimensions[2] + battery_headroom + lcd_panel_depth;

housing_to_board_margin = 0.5;
housing_side_wall_depth = 2;
housing_base_depth = 1;
housing_width = board_width + housing_side_wall_depth * 2 + housing_to_board_margin * 2;
housing_height = board_height + housing_side_wall_depth * 2 + housing_to_board_margin * 2;
housing_depth = electronics_depth + housing_base_depth;
housing_lower_corner_radius = 2;
housing_lower_fillet_size = 3;
housing_strap_connector_thickness = 3;
housing_to_strap_margin = 0.4;

housing_usbc_plug_cutout_width = 1.1;
housing_usbc_plug_cutout_height = 6;

watch_strap_width = 22;
watch_strap_thickness = 2;
watch_strap_length = 84;

watch_strap_connector_radius = 3;
watch_strap_connector_smoothing_radius = 24;
watch_strap_connector_hole_radius = 1;

watch_strap_end_corner_radius = 2;
watch_strap_hole_radius = 1.4;
