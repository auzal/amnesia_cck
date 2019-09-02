class Director {

  int img_index = 0;
  PImage [] img;
  float screen_brightness = 1;
  String state = "WAITING";
  String sub_state ="INTERVAL";
  int fire_time;
  int loop_counter;
  boolean glitch_flag = false;


  Director(PImage [] img_) {
    img = img_;
  }

  void render(PGraphics table, PGraphics whole_texture) {
    whole_texture.beginDraw();
    whole_texture.background(0);
    if (state.equals("ACTIVE")) {
      table.beginDraw();
      table.background(0);
      if (sub_state.equals("ON"))
        table.image(img[img_index], 0, 0);
        
      table.endDraw();
      if(glitch_flag){
        horizontalGlitch();
        glitch_flag = false;
      }
      whole_texture.image(table, SCREEN_X, SCREEN_Y);
    } else if (state.equals("WAITING")) {
    }
    whole_texture.endDraw();
  }

  void update() {
    if (state.equals("ACTIVE")) {
      if (sub_state.equals("ON")) {
        if (millis() - fire_time > ON_TIME) {
          sub_state = "INTERVAL";
          fire_time = millis();
        }
      } else  if (sub_state.equals("INTERVAL")) {
        if (millis() - fire_time > INTERVAL_TIME) {
          img_index ++;
          playRandomGlitch(0.1);
          if(random(10) < 3){
            glitch_flag = true;
          }
          sub_state = "ON";
          fire_time = millis();
          if (img_index > img.length-1) {
            loop_counter ++;
            img_index = 0;
            if (loop_counter > LOOPS) {
              state = "WAITING";
              fire_time = millis();
            }
          }
        }
      }
    } else if (state.equals("WAITING")) {
      if (millis() - fire_time > WAIT_TIME) {
        fire();
      }
    }
  }


  void setBrightness(float b) {
    screen_brightness = b;
  }

  void fire() {
    state = "ACTIVE";
    sub_state = "ON";
    img_index = 0;
    fire_time = millis();
    loop_counter = 0;
  }
}
