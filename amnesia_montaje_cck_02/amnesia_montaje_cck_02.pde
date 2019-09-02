PImage [] results; // acá cada capa de recortes
PGraphics screen;
int index = 0;
Director d;
SoundDirector sound;

PGraphics texture;
float processed_area;

boolean blackout = false;
boolean stand_by_flag = false;
int stand_by_timer_fire;
int stand_by_black_fire;
boolean attempting_stand_by = false;
boolean waiting_black = true;
int stand_by_fade = 0;
int glitch_counter;

//••••••••••••••••••••••••••••••••••••

void setup() {
  size(1280, 800, P2D);  // RESOLUCIóN DE PROYECTOR
  //fullScreen(P2D);
  noCursor();
  createPGraphics(); // el que lleva solo las tarjetas y el que lleva la proyección entera
  processImage(createTiledTexture(1));
  d = new Director(results);
  serialInit();
  polyInit();
  soundAndOscInit();
  //  s.ejecutarSonido(0, true, 0.9, 0.5, 1);
  d.fire();
  sound.loopSound(0,0.8);
}

//••••••••••••••••••••••••••••••••••••

void draw() {

  surface.setTitle(" AMENSIA || " + STATE+ " || FPS: " + nfc(frameRate, 1) );
  texture.beginDraw(); // empiezo a dibujar en el general
  //texture.fill(0, 80);
  //texture.rect(0, 0, texture.width, texture.height);
  //processed_area = (constrain(((height-mouseY)*1.0/height) * 4, 0.08, 1));
  //d.setBrightness(processed_area);  
  background(0, 0, 0);

  if (STATE.equals("RUNNING")) {

    d.update();
    d.render(screen, texture);
  } else if (STATE.equals("CALIBRATION")) {
    renderCalibration();
  }
  texture.endDraw(); // termino el dibujo general
  render.updateTexture(texture); // se lo paso al polígono mappeado
  render.render(); // lo dibujo
  render.update(); // y lo actualizo
  if (blackout) // si apagué todo
    background(0); // fondo negro
  n.update();
  n.render();
}

//••••••••••••••••••••••••••••••••••••

void mousePressed() {
  render.mousePressed();
  horizontalGlitch();

  //s.ejecutarSonidoRandom(1, 7);
}

//••••••••••••••••••••••••••••••••••••

void keyPressed() {
  if (!render.checkKeys()) {
    if (key == ' ') {
      // s.ejecutarSonido(0, true, 0.9, 0.5, 1);
      //  d.fire();
    } else if (key == 'b' || key == 'B') {
      blackout = !blackout;
      if (blackout) {
        n.createNotification("blackout on");
      } else {
        n.createNotification("blackout off");
      }
    } else if (keyCode == TAB) {
      if (STATE.equals("CALIBRATION")) {
        render.saveConfig();
        STATE = "RUNNING";
        d.fire();
      } else if (STATE.equals("RUNNING")) {
        STATE = "CALIBRATION";
      }
    }else if (key == 'r' || key == 'R') {
      if (STATE.equals("CALIBRATION")) {
        render.resetCalibration();
      }
    }
  }
}

//••••••••••••••••••••••••••••••••••••

void mouseDragged() {
  render.checkDrag();
}

//••••••••••••••••••••••••••••••••••••

void mouseReleased() {
  render.mouseReleased();
}

//••••••••••••••••••••••••••••••••••••

void mouseClicked() {
  render.mouseClicked();
}
