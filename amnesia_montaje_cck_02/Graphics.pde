void createPGraphics() {
  screen = createGraphics(SCREEN_WIDTH, SCREEN_HEIGHT);
  screen.beginDraw();
  screen.endDraw();
  texture = createGraphics(width, height);
}

void renderCalibration() {
  texture.pushStyle();
  texture.background(0);
  texture.fill(255, 150, 0, abs(sin(radians(frameCount*2)))*90);
  texture.stroke(255, 128);
  texture.rect(SCREEN_X + FACES_X, SCREEN_Y + FACES_Y, FACES_W, FACES_H);

  texture.strokeWeight(GRID_STROKE);
  texture.stroke(0);

  texture.pushMatrix();
  texture.translate(SCREEN_X, SCREEN_Y);
  texture.translate(FACES_X, FACES_Y);

  for (int i = 0; i < COLS+1; i ++) {
    texture.line(i*TILE_W, 0, i*TILE_W, SCREEN_HEIGHT);
  }

  for (int i = 0; i < ROWS+1; i ++) {
    texture.line(0, i*TILE_H, SCREEN_WIDTH, i*TILE_H);
  }

  texture.popMatrix();
  texture.popStyle();
}


PImage createTiledTexture(int dither_rad) {

  PImage [] faces;
  PGraphics result;
  PImage aux;
  faces = new PImage[FACECOUNT];

  result = createGraphics(SCREEN_WIDTH, SCREEN_HEIGHT);
  result.beginDraw();
  result.background(0);

  float tile_w = result.width/(COLS*1.0);

  float tile_h = tile_w / 1.5;
  float total_h = tile_h * ROWS;

  if (total_h > result.height) {

    tile_h = result.height / (ROWS*1.0);

    tile_w = tile_h * 1.5;
  }

  total_h = tile_h*ROWS;
  float total_w = tile_w*COLS;

  float margin_x = (result.width - total_w)/2;
  float margin_y = (result.height - total_h)/2;
  
  FACES_X = margin_x;
  FACES_Y = margin_y;
  TILE_W = tile_w;
  TILE_H = tile_h;
  FACES_W = total_w;
  FACES_H = total_h;

  for (int i = 0; i < faces.length; i ++) {
    String filename = "faces/" + (i+1) + ".jpg";
    faces[i] = loadImage(filename);
    faces[i].resize(int(tile_w), int(tile_h));

    destructiveShift(faces[i], 1.2);
  }

  result.pushMatrix();
  result.translate(margin_x, margin_y);


  for (int i = 0; i < COLS; i ++) {
    for (int j = 0; j < ROWS; j ++) {
      result.image(faces[int(random(faces.length))], i*tile_w, j*tile_h);
    }
  }

  result.popMatrix();
  result.endDraw();
  result.beginDraw();

  aux = result;
  aux = floydSteinberg(aux, dither_rad);
  result.image(aux, 0, 0);
  int margin = GRID_STROKE;
  result.stroke(0, 0, 0);
  result.strokeWeight(margin);
  result.pushMatrix();
  result.translate(margin_x, margin_y);
  for (int i = 0; i < COLS+1; i ++) {
    result.line(i*tile_w, 0, i*tile_w, total_h);
  }

  for (int i = 0; i < ROWS+1; i ++) {
    result.line(0, i*tile_h, total_w, i*tile_h);
  }

  result.popMatrix();

  result.endDraw();



 //result.save("out.png");
  return(result);
}


//••••••••••••••••••••••••••••••••••••

void processImage(PImage texture) {

  results = new PImage[LAYERS];
  IntList pix = new IntList(); // creo una lista de enteros
  int img_w =  int(texture.width / CELL_WIDTH); // determino el ancho de la imagen "semilla"
  int img_h =  int(texture.height / CELL_HEIGHT);// determino el alto de la imagen "semilla"
  int pix_amt = int(img_w * img_h);  // caculo la cantidad de 
  // bloques
  for (int i = 0; i < pix_amt; i++) {
    pix.append(i); // cargo una lista de bloques
  }
  pix.shuffle();
  int index = 0;
  for (int i = 0; i < LAYERS; i ++) {
    results[i] = createImage(texture.width, texture.height, ARGB);
    for (int j = 0; j < pix_amt / LAYERS; j++) {
      int x = indexToX(pix.get(index), img_w) * CELL_WIDTH;
      int y = indexToY(pix.get(index), img_w) * CELL_HEIGHT;
      results[i].copy(texture, x, y, CELL_WIDTH, CELL_HEIGHT, x, y, CELL_WIDTH, CELL_HEIGHT);
      index++;
    }
    results[i].filter(BLUR, BLUR_AMT);
    //out.save(i+ ".png");
  }
}


//••••••••••••••••••••••••••••••••••••

int indexToX(int i, int w) {
  return ( i % w);
}

//••••••••••••••••••••••••••••••••••••

int indexToY(int i, int w) {
  return ( i / w );
}

//••••••••••••••••••••••••••••••••••••

void horizontalGlitch() {
  screen.beginDraw();
  screen.pushStyle();
  screen.stroke(255);
  screen.strokeWeight(2);
  
  screen.pushMatrix();
  screen.translate(FACES_X, FACES_Y);

  int amt = int(random(80));

  for (int i = 0; i < amt; i++) {

    int x = int(random(FACES_W/CELL_WIDTH)) * CELL_WIDTH;
    int y = int(random(FACES_H/CELL_HEIGHT)) * CELL_HEIGHT;
    int w = int(random(10)) * CELL_WIDTH;
    //screen.stroke(texture.get(x, y));
    screen.line(x, y, x+w, y);
  }
  
  screen.popMatrix();

  screen.popStyle();
  screen.endDraw();
}

/**
 * BrightnessContrastController
 *
 * Shifts the global brightness and contrast of an image.
 *
 * Ported from Gimp's implementation, as explained by Pippin here:
 * http://pippin.gimp.org/image_processing/chap_point.html 
 * The following excerpts are from that--excellent btw--documentation:
 * "Changing the contrast of an image, changes the range of luminance values present. 
 *  Visualized in the histogram it is equivalent to expanding or compressing the histogram around the midpoint value. 
 *  Mathematically it is expressed as:
 *    new_value = (old_value - 0.5) × contrast + 0.5
 *  It is common to bundle brightness and control in a single operations, the mathematical formula then becomes:
 *   new_value = (old_value - 0.5) × contrast + 0.5 + brightness
 * The subtraction and addition of 0.5 is to center the expansion/compression of the range around 50% gray." 
 *
 * @author ale
 * @version 1.0
 */


/**
 * Shifts brightness and contrast in the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Image to be adjusted.
 * @param brightness
 *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
 * @param contrast
 *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
 */
public void destructiveShift(PImage img, int brightness, float contrast)
{
  img.loadPixels();
  int l = img.pixels.length;

  //Variables to hold single pixel color and its components 
  int c = 0;
  int a = 0;
  int r = 0;
  int g = 0;
  int b = 0;

  for (int i = 0; i < l; i++)
  {
    c = img.pixels[i];
    a = c >> 24 & 0xFF;
    r = adjustedComponent(c >> 16 & 0xFF, brightness, contrast);
    g = adjustedComponent(c >> 8  & 0xFF, brightness, contrast);
    b = adjustedComponent(c       & 0xFF, brightness, contrast);
    img.pixels[i] = a << 24 | r << 16 | g << 8 | b;
  }
  img.updatePixels();
}

/**
 * Shifts brightness in the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Image to be adjusted.
 * @param brightness
 *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
 */
public void destructiveShift(PImage img, int brightness)
{
  destructiveShift(img, brightness, 1.0);
}

/**
 * Shifts contrast in the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Image to be adjusted.
 * @param contrast
 *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
 */
public void destructiveShift(PImage img, float contrast)
{
  destructiveShift(img, 0, contrast);
}

/**
 * Shifts brightness and contrast in a defensive copy of the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Source image.
 * @param brightness
 *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
 * @param contrast
 *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
 * @return An adjusted defensive copy of the given image.
 */
public PImage nondestructiveShift(PImage img, int brightness, float contrast)
{
  PImage out = createImage(img.width, img.height, ARGB);
  img.loadPixels();
  out.loadPixels();
  int l = img.pixels.length;

  //Variables to hold single pixel color and its components 
  int c = 0;
  int a = 0;
  int r = 0;
  int g = 0;
  int b = 0;

  for (int i = 0; i < l; i++)
  {
    c = img.pixels[i];
    a = c >> 24 & 0xFF;
    r = adjustedComponent(c >> 16 & 0xFF, brightness, contrast);
    g = adjustedComponent(c >> 8  & 0xFF, brightness, contrast);
    b = adjustedComponent(c       & 0xFF, brightness, contrast);
    out.pixels[i] = a << 24 | r << 16 | g << 8 | b;
  }
  out.updatePixels();
  return out;
}  

/*
    * Shifts brightness in a defensive copy of the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Image to be adjusted.
 * @param brightness
 *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
 */
public void nondestructiveShift(PImage img, int brightness)
{
  nondestructiveShift(img, brightness, 1.0);
}

/**
 * Shifts contrast in a defensive copy of the given image. Keeps alpha of the source pixels.
 * 
 * @param img
 *            Image to be adjusted.
 * @param contrast
 *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
 */
public void nondestructiveShift(PImage img, float contrast)
{
  nondestructiveShift(img, 0, contrast);
} 

/**
 * Calculates the transformation of a single color component.
 * 
 * @param component
 *            Integer value of the component in a range 0-255.
 * @param brightness
 *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
 * @param contrast
 *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
 * @return The adjusted value of the component, constrained in its natural range 0-255.
 */
private int adjustedComponent(int component, int brightness, float contrast)
{
  component = int((component - 128) * contrast) + 128 + brightness;
  return component < 0 ? 0 : component > 255 ? 255 : component;
}  
