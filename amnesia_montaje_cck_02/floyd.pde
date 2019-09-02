PImage floydSteinberg(PImage img, int cell_size) {

  PImage src = img;
  PGraphics  res = createGraphics(src.width, src.height, JAVA2D);

  pushStyle();


  res.beginDraw();

  res.background(0);

  res.noStroke();

  noStroke();
  // noSmooth(); 


  int s = cell_size;



  for (int x = 0; x < src.width; x+=s) {
    for (int y = 0; y < src.height; y+=s) {
      color oldpixel = src.get(x, y);
      color newpixel = findClosestColor(oldpixel);
      float quant_error = brightness(oldpixel) - brightness(newpixel);
      src.set(x, y, newpixel);

      src.set(x+s, y, color(brightness(src.get(x+s, y)) + 7.0/16 * quant_error) );
      src.set(x-s, y+s, color(brightness(src.get(x-s, y+s)) + 3.0/16 * quant_error) );
      src.set(x, y+s, color(brightness(src.get(x, y+s)) + 5.0/16 * quant_error) );
      src.set(x+s, y+s, color(brightness(src.get(x+s, y+s)) + 1.0/16 * quant_error));


      color c = color(newpixel);   

      if (s==1)
        res.set(x, y, c);
      else if (s>1) {
        res.fill(c);
        res.rect(x, y, s, s);
      }
    }
  }

  res.endDraw();
  popStyle();

  return res;
}

// Threshold function
color findClosestColor(color in) {  
  color out;
  if (brightness(in) < 128) {
    out = color(0);
  } else {
    out = color(255);
  }


  return out;
}
