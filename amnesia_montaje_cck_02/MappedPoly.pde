
MappedPoly render;
PFont f;
Notification n;

void polyInit() {  
  f = loadFont("quick10.vlw");
  render = new MappedPoly();
  render.setFont(f);
  render.setId("amnesia");
  render.loadConfig();

  n = new Notification();
  n.setPosition(300, height-100);
  n.setFont(f);
}

class MappedPoly {

  ArrayList <Point> vertices;
  PImage texture;
  boolean calibrating = false;
  int calibration_vertex_index = 2;
  PVector [] texture_coords = new PVector [4];
  int divisions = 10;

  PVector [][] sub;

  DoubleClick dclick;

  int vertex_rect_size = 10;

  float center_x_coord;
  float center_y_coord;

  boolean moving_global = false;

  String id;

  PFont font;
  MappedPoly() {

    dclick = new DoubleClick(300);

    float init_x = random(100, width-100);
    float init_y = random(100, height-100);

    vertices = new ArrayList();

    Point aux = new Point(init_x + 20, init_y +20);
    vertices.add(aux);
    aux = new Point( init_x + 100, init_y + 20);
    vertices.add(aux);
    aux = new Point(init_x + 100, init_y + 100);
    vertices.add(aux);
    aux = new Point(init_x + 20, init_y + 100);
    vertices.add(aux);

    texture_coords [0] = new PVector(0, 0);
    texture_coords [1] = new PVector(1, 0);
    texture_coords [2] = new PVector(1, 1);
    texture_coords [3] = new PVector(0, 1);
    createSub();
    id = "id";
  }

  void updateTexture(PImage i) {

    texture = i;
  }

  void render() {

    pushStyle();


    renderTextureSub();

    if (calibrating)
      renderCalibration();

    popStyle();
  }



  void update() {

    center_x_coord = (lerp(vertices.get(0).getPosition().x, vertices.get(2).getPosition().x, 0.5) + lerp(vertices.get(1).getPosition().x, vertices.get(3).getPosition().x, 0.5))/2;
    center_y_coord = (lerp(vertices.get(0).getPosition().y, vertices.get(2).getPosition().y, 0.5) + lerp(vertices.get(1).getPosition().y, vertices.get(3).getPosition().y, 0.5))/2;

    if (dclick.getFlag()) {

      if (containsPoint(mouseX, mouseY)) {

        if (!calibrating)
          calibrating = true;
        else
          calibrating = false;
      } else {
        if (calibrating)
          calibrating = false;
      }
    }

    dclick.update();

    createSub();
  }

  void renderCalibration() {

    pushStyle();

    renderMatrix();

    noFill();
    stroke(255, 90);
    strokeWeight(1);
    line(mouseX, mouseY, vertices.get(calibration_vertex_index).x, vertices.get(calibration_vertex_index).y );
    strokeWeight(2);
    stroke(0, 255, 206);
    if (moving_global)
      fill(0, 255, 206, 90);
    else
      noFill(); 
    ellipse(center_x_coord, center_y_coord, 10, 10);

    noFill();

    beginShape();

    for (int i = 0; i < vertices.size(); i ++) {
      Point v = vertices.get(i);
      vertex(v.x, v.y);
    }

    endShape(CLOSE);

    for (int i = 0; i < vertices.size(); i ++) {
      Point v = vertices.get(i);
      noFill();
      stroke(255, 102, 0);
      rectMode(CENTER);
      rect(v.x, v.y, vertex_rect_size, vertex_rect_size);
      pushMatrix();
      translate(v.x, v.y);

      for (int j = 0; j < 4; j++) {
        line(5, 0, 10, 0);
        rotate(HALF_PI);
      }

      if (i == calibration_vertex_index && !moving_global) {
        pushStyle();
        fill(255, 255, 0, 160);
        noStroke();
        rotate(frameCount * 0.03);
        for (int j = 0; j < 4; j++) {
          triangle(20, 0, 35, -5, 35, 5);
          rotate(HALF_PI);
        }
        popStyle();
      }
      popMatrix();
    }

    renderId();
    popStyle();
  }



  void saveConfig() {

    String[] output = new String[4];

    for (int i = 0; i < vertices.size(); i ++) {
      output[i] = vertices.get(i).getPosition().x + "," + vertices.get(i).getPosition().y;
    }

    saveStrings("data/mappingconfig.txt", output);
  }

  void loadConfig() {



    String[] data = loadStrings("data/mappingconfig.txt");

    for (int i = 0; i < data.length; i ++) {


      String[] row = splitTokens(data[i], ",");

      vertices.get(i).setPosition( float(row[0]), float(row[1]) );
    }
  }

  void checkDrag() {
    if (calibrating) {

      if (moving_global) {

        for (int i = 0; i < vertices.size(); i ++) {
          vertices.get(i).move(mouseX-pmouseX, mouseY-pmouseY);
        }
      } else

        vertices.get(calibration_vertex_index).move(mouseX-pmouseX, mouseY-pmouseY);
    }
  }

  void mouseClicked() {

    checkVertexSelection();

    dclick.mouseClicked();
  }

  boolean checkKeys() {
    boolean ret = false;
    if (calibrating) {
      // ret = true;
      if (key == ENTER  || key == RETURN) {
        calibrating  = false;
        if (!calibrating)
          ret = false;
        saveConfig();
      } 
      if (keyCode == TAB) {
        calibration_vertex_index ++;
        calibration_vertex_index = calibration_vertex_index % vertices.size();
        ret = true;
      } else if (keyCode == UP) {
        vertices.get(calibration_vertex_index).move(0, -1);
        ret = true;
      } else if (keyCode == DOWN) {
        vertices.get(calibration_vertex_index).move(0, 1);
        ret = true;
      } else if (keyCode == RIGHT) {
        vertices.get(calibration_vertex_index).move(1, 0);
        ret = true;
      } else if (keyCode == LEFT) {
        vertices.get(calibration_vertex_index).move(-1, 0);
        ret = true;
      }
    }
    return ret;
  }


  // taken from:
  // http://hg.postspectacular.com/toxiclibs/src/tip/src.core/toxi/geom/Polygon2D.java
  boolean containsPoint(float px, float py) {
    int num = vertices.size();
    int i, j = num - 1;
    boolean oddNodes = false;
    for (i = 0; i < num; i++) {
      PVector vi = vertices.get(i).getPosition();
      PVector vj = vertices.get(j).getPosition();
      if (vi.y < py && vj.y >= py || vj.y < py && vi.y >= py) {
        if (vi.x + (py - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < px) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }
    return oddNodes;
  }

  void checkVertexSelection() {
    if (calibrating) {

      moving_global = false;
      for (int i = 0; i < vertices.size(); i ++) {
        if (dist(mouseX, mouseY, vertices.get(i).getPosition().x, vertices.get(i).getPosition().y) < vertex_rect_size/2) {
          calibration_vertex_index = i;
          break;
        }
      }
    }
  }

  void mousePressed() {
    if (calibrating) {
      if (dist(mouseX, mouseY, center_x_coord, center_y_coord) < 5) {
        moving_global = true;
      }
    }
  }

  void mouseReleased() {
    moving_global = false;
  }

  void setId(String id_) {
    id = id_.toUpperCase();
  }

  String getId() {
    return id;
  }

  void setFont(PFont f_) {
    font = f_;
  }

  void renderId() {
    pushStyle();

    textAlign(CENTER);
    rectMode(CENTER);
    if (font != null) {
      textFont(font);
    }

    fill(0, 255, 206);
    noStroke();

    float rect_width = textWidth(id) + 5;
    float rect_height = textAscent() + textDescent();

    float rect_x = lerp(vertices.get(0).getPosition().x, vertices.get(1).getPosition().x, 0.5);
    float rect_y = lerp(vertices.get(0).getPosition().y, vertices.get(1).getPosition().y, 0.5);

    float ang = atan2(vertices.get(1).getPosition().y - vertices.get(0).getPosition().y, vertices.get(1).getPosition().x - vertices.get(0).getPosition().x);

    pushMatrix();

    translate(rect_x, rect_y);
    rotate(ang);
    translate(0, -rect_height/2);
    rect(0, 0, rect_width, rect_height);

    fill(0);
    text(id, 1, 3);

    popMatrix();




    popStyle();
  }

  void createSub() {
    sub = new PVector[divisions+1][divisions+1];

    stroke(200, 0, 0);

    for (int y = 0; y <= divisions; y++) {
      float lerp_amt = map(y, 0, divisions, 0, 1);
      PVector a = new PVector(lerp(vertices.get(0).x, vertices.get(3).x, lerp_amt), lerp(vertices.get(0).y, vertices.get(3).y, lerp_amt));
      PVector b = new PVector(lerp(vertices.get(1).x, vertices.get(2).x, lerp_amt), lerp(vertices.get(1).y, vertices.get(2).y, lerp_amt));
      // ellipse(a.x, a.y, 10, 10);
      // ellipse(b.x, b.y, 10, 10);
      for (int x = 0; x <= divisions; x++) {
        lerp_amt = map(x, 0, divisions, 0, 1);
        PVector aux = new PVector(lerp(a.x, b.x, lerp_amt), lerp(a.y, b.y, lerp_amt));
        sub [y][x] = aux;
        //  ellipse(sub[y][x].x, sub[y][x].y, 5, 5);
      }
    }
  }

  void renderTextureSub() { 
    for (int y = 0; y < divisions; y++) {
      for (int x = 0; x < divisions; x++) {
        //fill(random(255));
        beginShape();
        noStroke();
        texture(texture);
        tint(255);
        textureMode(NORMAL);
        vertex(sub[y][x].x, sub[y][x].y, map(x, 0, divisions, 0, 1 ), map(y, 0, divisions, 0, 1 ));
        vertex(sub[y][x+1].x, sub[y][x+1].y, map(x+1, 0, divisions, 0, 1 ), map(y, 0, divisions, 0, 1 ));
        vertex(sub[y+1][x+1].x, sub[y+1][x+1].y, map(x+1, 0, divisions, 0, 1 ), map(y+1, 0, divisions, 0, 1 ));
        vertex(sub[y+1][x].x, sub[y+1][x].y, map(x, 0, divisions, 0, 1 ), map(y+1, 0, divisions, 0, 1 ));
        endShape(CLOSE);
      }
    }
  }

  void renderMatrix() {
    pushStyle();
    stroke(255, 128);
    strokeWeight(2);
    noFill();
    for (int i = 0; i < sub.length; i ++) {
      for (int j = 0; j < sub[i].length; j ++) {
        pushMatrix();
        translate(sub[i][j].x, sub[i][j].y);
        line(-3, 0, 3, 0);
        line(0, -3, 0, 3);
        popMatrix();
      }
    }
    popStyle();
  }

  void resetCalibration() {
    vertices.get(0).setPosition(0, 0);
    vertices.get(1).setPosition(width, 0);
    vertices.get(2).setPosition(width, height);
    vertices.get(3).setPosition(0, height);
  }
}

// POINT POINT POINT POINT POINT POINT POINT POINT POINT POINT POINT POINT 

class Point {

  float x;
  float y;


  Point() {

    x = 0;
    y = 0;
  }

  Point(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void setPosition(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void move(float dx, float dy) {
    x += dx;
    y += dy;
  }

  PVector getPosition() {

    return new PVector(x, y);
  }
}

// DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK DOUBLECLICK 

class DoubleClick {

  int first_click_x;
  int first_click_y;

  int first_click_time;

  int time_threshold;

  boolean waiting_for_second = false;

  boolean double_click_flag = false;

  DoubleClick(int time_thresh) {
    time_threshold = time_thresh;
  }

  void mouseClicked() {
    if (!waiting_for_second) {
      waiting_for_second = true;
      first_click_time = millis();
    } else if (millis() - first_click_time < time_threshold) {
      waiting_for_second = false;
      double_click_flag = true;
    } else if (millis() - first_click_time > time_threshold) {
      waiting_for_second = true;
      first_click_time = millis();
    }
  }

  void update() {
    if ( double_click_flag )
      double_click_flag = false;
  }

  void lowerFlag() {
    double_click_flag = false;
  }

  boolean getFlag() {
    return double_click_flag;
  }
}
