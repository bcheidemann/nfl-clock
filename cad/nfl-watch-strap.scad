include <nfl-watch-variables.scad>

module watch_strap_base() {
  opp = watch_strap_connector_smoothing_radius + watch_strap_thickness - watch_strap_connector_radius;
  hyp = watch_strap_connector_smoothing_radius + watch_strap_connector_radius;
  adj = opp / tan(asin(opp / hyp));

  difference() {
    translate([0, watch_strap_width / 2, 0])
    rotate([90, 0, 0])
    linear_extrude(height = watch_strap_width)
    difference() {
      union() {
        translate([0, watch_strap_connector_radius, 0])
        circle(watch_strap_connector_radius, $fn = 32);
        square([
          watch_strap_length,
          watch_strap_thickness,
        ]);
        polygon([
          [0, 0],
          [0, watch_strap_connector_radius],
          [adj, watch_strap_thickness + watch_strap_connector_smoothing_radius],
          [adj, 0],
        ]);
      }
      translate([
        adj,
        watch_strap_connector_smoothing_radius + watch_strap_thickness,
        0,
      ])
      circle(watch_strap_connector_smoothing_radius, $fn = 64);
      translate([0, watch_strap_connector_radius])
      circle(watch_strap_connector_hole_radius, $fn = 32);
    }

    linear_extrude(height = watch_strap_thickness)
    difference() {
      translate([
        watch_strap_length - watch_strap_end_corner_radius,
        -watch_strap_width / 2,
      ])
      square([watch_strap_end_corner_radius, watch_strap_width]);
      hull() {
        translate([
          watch_strap_length - watch_strap_end_corner_radius,
          +(watch_strap_width / 2 - watch_strap_end_corner_radius),
        ])
        circle(watch_strap_end_corner_radius, $fn = 16);
        translate([
          watch_strap_length - watch_strap_end_corner_radius,
          -(watch_strap_width / 2 - watch_strap_end_corner_radius),
        ])
        circle(watch_strap_end_corner_radius, $fn = 16);
      }
    }
  }
}

module watch_strap_with_holes() {
  color("#282828")
  render() {
    difference() {
      watch_strap_base();

      for (pos = [watch_strap_width / 2 : watch_strap_width / 2 : 5 * watch_strap_width / 2]) {
        translate([watch_strap_length - pos, 0, 0])
        cylinder(h = watch_strap_thickness, r = watch_strap_hole_radius, $fn = 16);
      }
    }
  }
}
module watch_strap_with_buckle() {
  color("#282828")
  render() {
    watch_strap_base();
  }
}
