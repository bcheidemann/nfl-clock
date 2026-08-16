include <nfl-watch-variables.scad>
include <nfl-watch-strap.scad>

echo("housing_depth", housing_depth);

module board(dimensions, corner_radius) {
  color("green")
  linear_extrude(height = dimensions[2])
  minkowski() {
    square(
      [dimensions[0] - corner_radius * 2, dimensions[1] - corner_radius * 2],
      center = true
    );
    circle(corner_radius, $fn = 32);
  }
}

module threaded_insert() {
  color("gold")
  cylinder(h = 2.5, r = 1.7, $fn = 16);
}

module usbc_port() {
  usbc_port_border_radius = 0.98;

  color("silver")
  linear_extrude(height = usbc_port_depth)
  minkowski() {
    square(
      [
        usbc_port_height - usbc_port_border_radius * 2,
        usbc_port_width - usbc_port_border_radius * 2,
      ],
      center = true
    );
    circle(0.98, $fn = 16);
  }
}

module button() {
  color("grey")
  translate([-0.5, 0, 1])
  cube([1, 2, 1], center = true);

  color("white")
  translate([1.33, 0, 1])
  cube([2.66, 4.56, 2], center = true);
}

module mx1_25_battery_header() {
  color("white")
  cube(mx1_25_battery_header_dimensions);
}

module esp32_s3() {
  color("green")
  render() {
    difference() {
      board([board_width, board_height, board_depth], board_corner_radius);
      translate([0, 0, -1])
      linear_extrude(height = 4)
      polygon([
        [-board_width / 2, -12],
        [-board_width / 2, +12],
        [-board_width / 2 + 1.5, +10.5],
        [-board_width / 2 + 1.5, -10.5],
      ]);
    }
  }

  translate([
    -board_width / 2 + 1.7 + 0.1,
    -29 / 2,
    board_depth,
  ])
  threaded_insert();

  translate([
    -board_width / 2 + 1.7 + 0.1,
    29 / 2,
    board_depth,
  ])
  threaded_insert();

  translate([
    board_width / 2 - 1.7 - 0.1,
    -29 / 2,
    board_depth,
  ])
  threaded_insert();

  translate([
    board_width / 2 - 1.7 - 0.1,
    29 / 2,
    board_depth,
  ])
  threaded_insert();

  rotate([0, 90, 0])
  translate([-1.33 - board_depth, 0, 8])
  usbc_port();

  translate([
    -board_width / 2 + 1.5,
    +button_spacing,
    1,
  ])
  button();

  translate([
    -board_width / 2 + 1.5,
    0,
    1,
  ])
  button();

  translate([
    -board_width / 2 + 1.5,
    -button_spacing,
    1,
  ])
  button();

  translate([
    board_width / 2 - mx1_25_battery_header_dimensions[0] - 2.15,
    board_height / 2 - mx1_25_battery_header_dimensions[1] - 7.5,
    1,
  ])
  mx1_25_battery_header();
}

module lcd_panel() {
  color("black")
  linear_extrude(height = lcd_panel_depth)
  minkowski() {
    square(
      [board_width - board_corner_radius * 2, board_height - board_corner_radius * 2],
      center = true
    );
    circle(board_corner_radius, $fn = 32);
  }
}

module battery() {
  color("grey")
  translate([
    -battery_dimensions[0] / 2,
    -battery_dimensions[1] / 2,
    0,
  ])
  cube(battery_dimensions);
}


module electronics() {
  translate([
    0,
    0,
    esp32_s3_depth + battery_dimensions[2] + battery_headroom + housing_base_depth,
  ])
  rotate([0, 180, 180])
  esp32_s3();

  translate([
    0,
    0,
    esp32_s3_depth + 1 + battery_dimensions[2] + battery_headroom + housing_base_depth,
  ])
  lcd_panel();

  translate([
    battery_offset[0],
    battery_offset[1],
    housing_base_depth,
  ])
  battery();
}

module housing_cross_section() {
  union() {
    translate([housing_lower_corner_radius, housing_lower_corner_radius])
    intersection() {
      circle(housing_lower_corner_radius, $fn = 16);
      translate([-housing_lower_corner_radius, -housing_lower_corner_radius])
      square([housing_lower_corner_radius, housing_lower_corner_radius]);
    }
    translate([0, housing_lower_corner_radius])
    square([housing_side_wall_depth, housing_depth - housing_lower_corner_radius - housing_side_wall_depth]);
    translate([housing_side_wall_depth, housing_depth - housing_side_wall_depth])
    intersection() {
      circle(housing_side_wall_depth, $fn = 32);
      translate([-housing_side_wall_depth, 0])
      square([housing_side_wall_depth, housing_side_wall_depth]);
    }
    // translate([housing_side_wall_depth, housing_depth - lcd_panel_depth])
    polygon([
      [
        housing_side_wall_depth,
        housing_depth,
      ],
      [
        housing_side_wall_depth + housing_to_board_margin,
        housing_depth,
      ],
      [
        housing_side_wall_depth + housing_to_board_margin,
        housing_depth - lcd_panel_depth,
      ],
      [
        housing_side_wall_depth,
        housing_depth - lcd_panel_depth - housing_to_board_margin,
      ],
    ]);
    translate([housing_lower_corner_radius, 0])
    square([housing_side_wall_depth - housing_lower_corner_radius, housing_lower_corner_radius]);
    translate([housing_side_wall_depth, 0])
    square([housing_lower_fillet_size, housing_base_depth]);
    translate([housing_side_wall_depth, housing_base_depth])
    polygon([
      [0, 0],
      [0, housing_lower_fillet_size],
      [housing_lower_fillet_size, 0],
    ]);
  }
}

module housing_side_wall(length) {
  color("red")
  translate([0, length / 2, 0])
  rotate([90, 0, 0])
  linear_extrude(height = length)
  housing_cross_section();
}

module housing_corner_wall() {
  size = housing_side_wall_depth + housing_lower_fillet_size + board_corner_radius / 2;

  color("red")
  intersection() {
    rotate_extrude($fn = 32)
    translate([
      -size,
      0,
    ])
    translate([0,0,0])
    housing_cross_section();
    cube([
      size,
      size,
      housing_depth,
    ]);
  }
}

module housing_sides() {
  translate([
    -(board_width / 2 + housing_side_wall_depth + housing_to_board_margin),
    0,
    0,
  ])
  housing_side_wall(board_height - board_corner_radius * 2);

  translate([
    +(board_width / 2 + housing_side_wall_depth + housing_to_board_margin),
    0,
    0,
  ])
  rotate([0, 0, 180])
  housing_side_wall(board_height - board_corner_radius * 2);

  translate([
    0,
    -(board_height / 2 + housing_side_wall_depth + housing_to_board_margin),
    0,
  ])
  rotate([0, 0, 90])
  housing_side_wall(board_width - board_corner_radius * 2);

  translate([
    0,
    +(board_height / 2 + housing_side_wall_depth + housing_to_board_margin),
    0,
  ])
  rotate([0, 0, -90])
  housing_side_wall(board_width - board_corner_radius * 2);

  housing_corner_wall_offset_x = board_width / 2 - board_corner_radius;
  housing_corner_wall_offset_y = board_height / 2 - board_corner_radius;

  translate([
    housing_corner_wall_offset_x,
    housing_corner_wall_offset_y,
    0,
  ])
  rotate([0, 0, 0])
  housing_corner_wall();

  translate([
    -housing_corner_wall_offset_x,
    housing_corner_wall_offset_y,
    0,
  ])
  rotate([0, 0, 90])
  housing_corner_wall();

  translate([
    -housing_corner_wall_offset_x,
    -housing_corner_wall_offset_y,
    0,
  ])
  rotate([0, 0, 180])
  housing_corner_wall();

  translate([
    housing_corner_wall_offset_x,
    -housing_corner_wall_offset_y,
    0,
  ])
  rotate([0, 0, 270])
  housing_corner_wall();
}

module housing_base() {
  color("red")
  translate([0, 0, housing_base_depth / 2])
  cube([
    (board_width + housing_side_wall_depth*2 + housing_to_board_margin*2) - (housing_side_wall_depth + housing_lower_fillet_size)*2,
    (board_height + housing_side_wall_depth*2 + housing_to_board_margin*2) - (housing_side_wall_depth + housing_lower_fillet_size)*2,
    housing_base_depth,
  ], center = true);
}

module housing_strap_connector() {
  translate([0, 0, -housing_strap_connector_thickness / 2])
  linear_extrude(height = housing_strap_connector_thickness)
  hull() {
    translate([0, watch_strap_connector_radius])
    circle(watch_strap_connector_radius, $fn = 32);
    translate([watch_strap_connector_radius + housing_to_strap_margin, 0])
    polygon([
      [0, 0],
      [0, housing_depth - housing_side_wall_depth],
      [housing_lower_corner_radius, housing_depth - housing_side_wall_depth],
      [housing_lower_corner_radius * 2 + 2, 0],
    ]);
  }
}

module housing_strap_connectors() {
  strap_hole_offset = (housing_height / 2 + watch_strap_connector_radius + housing_to_strap_margin);
  strap_connector_spacing = (watch_strap_width / 2 + housing_to_strap_margin + housing_strap_connector_thickness / 2);

  translate([
    -strap_connector_spacing,
    -strap_hole_offset,
    0,
  ])
  rotate([90, 0, 90])
  housing_strap_connector();

  translate([
    +strap_connector_spacing,
    -strap_hole_offset,
    0,
  ])
  rotate([90, 0, 90])
  housing_strap_connector();

  translate([
    -strap_connector_spacing,
    +strap_hole_offset,
    0,
  ])
  rotate([90, 0, -90])
  housing_strap_connector();

  translate([
    +strap_connector_spacing,
    +strap_hole_offset,
    0,
  ])
  rotate([90, 0, -90])
  housing_strap_connector();
}

module housing_electronics_support() {
  color("red")
  translate([
    0,
    0,
    housing_base_depth,
  ])
  cylinder(
    h = battery_dimensions[2] + battery_headroom + board_depth,
    d = 3.45 * 1.1,
    $fn = 16
  );
}

module housing_electronics_supports() {
  translate([
    -board_width / 2 + 1.7 + 0.1,
    -29 / 2,
    0,
  ])
  housing_electronics_support();

  translate([
    -board_width / 2 + 1.7 + 0.1,
    29 / 2,
    0,
  ])
  housing_electronics_support();

  translate([
    board_width / 2 - 1.7 - 0.1,
    -29 / 2,
    0,
  ])
  housing_electronics_support();

  translate([
    board_width / 2 - 1.7 - 0.1,
    29 / 2,
    0,
  ])
  housing_electronics_support();
}

module housing_usbc_plug_cutout() {
  translate([
    board_width/2 + housing_to_board_margin + 0.8,
    0,
    esp32_s3_depth + battery_dimensions[2] + battery_headroom + housing_base_depth - board_depth - usbc_port_height / 2,
  ])
  rotate([90, 0, 90])
  linear_extrude(housing_side_wall_depth + housing_lower_fillet_size + 2)
  hull() {
    translate([
      +(housing_usbc_plug_cutout_width / 2 - housing_usbc_plug_cutout_height),
      0,
    ])
    circle(housing_usbc_plug_cutout_height / 2, $fn = 16);
    translate([
      -(housing_usbc_plug_cutout_width / 2 - housing_usbc_plug_cutout_height),
      0,
    ])
    circle(housing_usbc_plug_cutout_height / 2, $fn = 16);
  }
}

module housing_button_cutout() {
  linear_extrude(height = 1.2)
  hull() {
    translate([0, +1.6])
    circle(2.2, $fn=16);
    translate([0, -1.6])
    circle(2.2, $fn=16);
  }
  linear_extrude(height = housing_side_wall_depth + housing_lower_fillet_size)
  rotate(45)
  square([3, 3], center = true);
  translate([0, 0, housing_side_wall_depth])
  linear_extrude(height = housing_lower_fillet_size)
  rotate(45)
  square([4, 4], center = true);
}

module housing_button_cutouts() {
  vertical_offset = (housing_lower_corner_radius + (housing_depth - housing_side_wall_depth)) / 2;

  translate([
    -housing_width / 2,
    -button_spacing,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button_cutout();

  translate([
    -housing_width / 2,
    0,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button_cutout();

  translate([
    -housing_width / 2,
    +button_spacing,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button_cutout();
}

module housing_display_cable_cutout() {
  translate([
    -display_cable_cutout_width/2,
    board_height/2,
    housing_depth - display_cable_cutout_height,
  ])
  intersection() {
    cube([
      display_cable_cutout_width,
      display_cable_cutout_depth,
      display_cable_cutout_height,
    ]);
    union() {
      translate([
        display_cable_cutout_depth,
        0,
        0,
      ])
      cube([
        display_cable_cutout_width - display_cable_cutout_depth * 2,
        display_cable_cutout_depth,
        display_cable_cutout_height,
      ]);
      translate([
        display_cable_cutout_depth,
        0,
        0,
      ])
      cylinder(
        h = display_cable_cutout_height,
        d = display_cable_cutout_depth * 2,
        $fn = 24
      );
      translate([
        display_cable_cutout_depth + display_cable_cutout_width - display_cable_cutout_depth * 2,
        0,
        0,
      ])
      cylinder(
        h = display_cable_cutout_height,
        d = display_cable_cutout_depth * 2,
        $fn = 24
      );
    }
  }
}

module housing() {
  difference() {
    union() {
      housing_sides();
      housing_base();
      housing_strap_connectors();
      housing_electronics_supports();
    }
    color("red")
    housing_usbc_plug_cutout();
    housing_button_cutouts();
    housing_display_cable_cutout();
  }
}

module housing_button() {

  color(color_black_rubber)
  translate([0, 0, -1])
  linear_extrude(height = 1.2)
  hull() {
    translate([0, +1.6])
    circle(2.2, $fn=16);
    translate([0, -1.6])
    circle(2.2, $fn=16);
  }
  color(color_black_rubber)
  render() {
    difference() {
      union() {
        linear_extrude(height = housing_side_wall_depth)
        rotate(45)
        square([3, 3], center = true);
        translate([0, 0, housing_side_wall_depth])
        linear_extrude(height = housing_to_board_margin + 0.5)
        rotate(45)
        square([4, 4], center = true);
      }
      translate([-2, 0, 0])
      linear_extrude(height = housing_side_wall_depth + housing_to_board_margin + 1)
      square([2, 4], center = true);
    }
  }
}

module housing_buttons() {
  vertical_offset = (housing_lower_corner_radius + (housing_depth - housing_side_wall_depth)) / 2;

  translate([
    -housing_width / 2,
    -button_spacing,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button();

  translate([
    -housing_width / 2,
    0,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button();

  translate([
    -housing_width / 2,
    +button_spacing,
    vertical_offset,
  ])
  rotate([0, 90, 0])
  housing_button();
}

// electronics();

color("red")
render() {
  intersection() {
    housing();
    // color("red")
    // translate([-999,0,0])
    // cube([999, 999, 999]);
  }
}

// housing_buttons();

// translate([0, (housing_height / 2 + watch_strap_connector_radius + housing_to_strap_margin), 0])
// rotate([0, 0, 90])
// watch_strap_with_holes();

// translate([0, -(housing_height / 2 + watch_strap_connector_radius + housing_to_strap_margin), 0])
// rotate([0, 0, 270])
// watch_strap_with_buckle();

// %housing_usbc_plug_cutout();
