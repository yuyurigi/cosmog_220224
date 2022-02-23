// space filling box
class Star {

  int x;
  int y;
  int d, d2;
  color myc, myc1, myc2;
  float ro;
  boolean okToDraw;
  boolean chaste = true;
  int shapeRandom, colorRandom, colorAlphaRandom, mnPoints;
  color[] colorData;
  color newStrokeColor;
  int min = 15; //星のサイズの最小値（１５以下は描かれない）
  int kumo = 7; //雲のもくもくの数
  float addAng = 360/kumo;
  RShape[] shp1 = new RShape[kumo];
  RShape shp2;
  RShape shp3;

  Star() {
    // random initial conditions
    selfinit();
  }

  void selfinit() {
    okToDraw = false;
    x = int(dimborder+random(width-dimborder*2));
    y = int(dimborder+random(height-dimborder*2));
    d = 0;
    d2 = int(random(20, 50)); //丸のサイズの最大値
    myc = get(x, y);
    myc1 = readBackground(x, y, backImage2);
    myc2 = readBackground2(x, y, pg);
    if (myc == backColor && time < 600) {
      //背景色の上に図形を描くとき、timeが600までのとき、
      //雲が出る確率をすこし高くする
      float s = random(1);
      if (s<0.6) {
        shapeRandom = 0;
      } else {
        shapeRandom = int(random(5)); //形のランダム値
      }
    } else {
      shapeRandom = int(random(1, 5));
    }
    colorRandom = int(random(colors.length)); //塗り色のランダム値
    //colorAlphaRandom = int(random(180, 255)); //透明度のランダム値
    colorAlphaRandom = 255;
    if (myc != backColor) {
      //図形の上に描かれる図形のstrokeカラー
      PGraphics pg1 = createGraphics(1, 1);
      pg1.beginDraw();
      pg1.noStroke();
      pg1.fill(colors[colorRandom]);
      pg1.rect(0, 0, 1, 1);
      pg1.fill(strokeColor, 100);
      pg1.rect(0, 0, 1, 1);
      pg1.endDraw();
      newStrokeColor = readBackground2(0, 0, pg1);
    } else {
      //背景色の上に描かれる図形のstrokeカラー
      newStrokeColor = color(strokeColor, 200);
    }
    ro = random(TWO_PI); //図形の回転のランダム値
    mnPoints = 5 + (int)random(1, 5);
    d2 = int(random(20, 50)); //丸のサイズの最大値
  }


  void draw() {
    expand();

    if (okToDraw) {

      if (d>min) { //星のサイズの最小値
        //↓変更するときはrewritePg()のほうも変更する
        switch(shapeRandom) {
        case 0 :
          cloud(x, y, d);
          break;
        case 1 :
          maru(x, y, d);
          break;
        case 2:
          drawTwinkleStar(x, y, d);
          break;
        case 3:
          twinkle(x, y, d, mnPoints);
          break;
        case 4:
          star(x, y, d);
          break;
        }
        blendMode(SCREEN);
        tint(colors[colorRandom], 150);
        if (shapeRandom == 1) { //○のとき
          image(dot, x, y, d*2, d*2);
        } else {
          image(dot, x, y, d*3, d*3);
        }
        blendMode(BLEND);
      }
    }

    rewritePg();
  }

  void expand() {
    int obstructions = 0;

    //キャラの上に図形を描かないようにする
    int check = 0;

    if (myc1 != color(0, 0, 0)) {
      check += 1;
    }

    if (check > 0) {
      obstructions += 1;
    }

    // look for obstructions around perimeter at width d
    //int obstructions = 0;
    colorData = new color[360];
    for (int ang=0; ang<360; ang++) {
      float rad = radians(ang);
      float x2 = int(x + ( (d/2+5) * cos(rad)));
      float y2 = int(y + ( (d/2+5) * sin(rad)));
      colorData[ang] = readBackground2(int(x2), int(y2), pg);
    }

    for (int l=0; l<colorData.length-1; l++) {
      if (colorData[l] != myc2) {
        obstructions += 1;
      }
      if (obstructions > 0) {
        break;
      }
    }

    if ((shapeRandom == 1) && (d > d2)) { //図形がmaruのときだけ大きくなりすぎないようにする
      obstructions += 1;
    }

    if (obstructions>0) {
      // reset
      if (chaste) {
        makeNewStar();
        chaste = false;
      }
    } else {
      d += 2;
      okToDraw = true;
    }
  }

  color readBackground(int x, int y, PImage img) {
    // translate into ba image dimensions
    int ax = int(x * (img.width*1.0)/width);
    int ay = int(y * (img.height*1.0)/height);

    color c = img.pixels[ay*img.width+ax];
    return c;
  }

  color readBackground2(int x, int y, PGraphics pg) {
    int ax = int(x * (pg.width*1.0)/width);
    int ay = int(y * (pg.height*1.0)/height);

    color c = pg.pixels[ay*pg.width+ax];
    return c;
  }

  void cloud(int x, int y, int radius) {
    shp2 = RShape.createEllipse(0, 0, radius*0.2, radius*0.2);
    float ang = 0;
    for (int i = 0; i < kumo; i++) {
      float rad = radians(ang);
      float x2 = 0 + (radius*0.25*cos(rad));
      float y2 = 0 + (radius*0.25*sin(rad));
      float rad2 = radius*0.5;
      shp1[i] = RShape.createEllipse(x2, y2, rad2, rad2);
      ang += addAng;
    }
    for (int i = 0; i < kumo; i++) {
      if (i == 0) {
        shp3 = RG.union(shp2, shp1[i]);
      } else {
        shp3 = RG.union(shp3, shp1[i]);
      }
    }
    pushMatrix();
    translate(x, y);
    fill(colors[colorRandom], colorAlphaRandom);
    stroke(newStrokeColor);
    strokeWeight(sw);
    RG.shape(shp3);
    popMatrix();
  }

  void star(int x, int y, int radius) { //☆
    float size = float(radius)*0.89;

    pushMatrix();
    translate(x, y);
    fill(colors[colorRandom], colorAlphaRandom);
    stroke(newStrokeColor);
    strokeWeight(sw);
    rotate(ro);
    beginShape();
    vertex(-0.089*size, -0.4204*size);
    bezierVertex(-0.0404*size, -0.5187*size, 0.0388*size, -0.5187*size, 0.0874*size, -0.4204*size);
    vertex(0.1754*size, -0.2221*size);
    vertex(0.3724*size, -0.2136*size);
    bezierVertex(0.4806*size, -0.1977*size, 0.5051*size, -0.1224*size, 0.4267*size, -0.046*size);
    vertex(0.2842*size, 0.093*size);
    vertex(0.3179*size, 0.2891*size);
    bezierVertex(0.3363*size, 0.397*size, 0.2722*size, 0.4436*size, 0.1753*size, 0.3926*size);
    vertex(-0.0008*size, 0.3*size);
    vertex(-0.1769*size, 0.3926*size);
    bezierVertex(-0.2738*size, 0.4436*size, -0.3379*size, 0.397*size, -0.3195*size, 0.2891*size);
    vertex(-0.2858*size, 0.093*size);
    vertex(-0.4283*size, -0.046*size);
    bezierVertex(-0.5067*size, -0.1224*size, -0.4822*size, -0.1978*size, -0.3739*size, -0.2135*size);
    vertex(-0.177*size, -0.2421*size);
    endShape(CLOSE);
    popMatrix();
  }

  void twinkle(int x, int y, int radius, int nPoints) { //*
    pushMatrix();
    translate(x, y);
    rotate(ro);
    float angle = TWO_PI / nPoints;
    float angle2 = angle / 2;
    float origAngle = 0.0;
    float rad1 = radius/2*0.95;
    float rad2 = rad1/4;

    fill(colors[colorRandom], colorAlphaRandom);
    stroke(newStrokeColor);
    strokeWeight(sw);
    strokeJoin(ROUND);
    beginShape();
    for (int i = 0; i < nPoints; i++)
    {
      float y1 = rad1 * sin(origAngle);
      float x1 = rad1 * cos(origAngle);
      float y2 = rad2 * sin(origAngle + angle2);
      float x2 = rad2 * cos(origAngle + angle2);
      vertex(x1, y1);
      vertex(x2, y2);
      origAngle += angle;
    }
    endShape(CLOSE);
    popMatrix();
  }

  void drawTwinkleStar(int x, int y, int radius) { //+
    pushMatrix();
    translate(x, y);
    stroke(newStrokeColor);
    strokeWeight(sw);
    fill(colors[colorRandom], colorAlphaRandom);
    beginShape();
    for (int theta = 0; theta < 360; theta++) {
      vertex(radius*0.35 * pow(cos(radians(theta)), 3), radius*0.35 * 1.4 * pow(sin(radians(theta)), 3));
    }
    endShape(CLOSE);
    popMatrix();
  }

  void maru(int x, int y, int rad) { //○
    stroke(newStrokeColor);
    strokeWeight(sw);
    fill(colors[colorRandom], colorAlphaRandom);
    ellipse(x, y, rad*0.5, rad*0.5);
  }

  /* PGraphics -----------------------------------------------------*/

  void rewritePg() {
    pg.beginDraw();
    pg.ellipseMode(CENTER);
    pg.shapeMode(CENTER);

    if (d>min) { //星のサイズの最小値
      switch(shapeRandom) {
      case 0 :
        cloud2(x, y, d);
        break;
      case 1 :
        maru2(x, y, d);
        break;
      case 2:
        drawTwinkleStar2(x, y, d);
        break;
      case 3:
        twinkle2(x, y, d, mnPoints);
        break;
      case 4:
        star2(x, y, d);
        break;
      }
    }
    pg.endDraw();
  }

  void cloud2(int x, int y, int radius) {
    if (myc2 == color(0)) {
      pg.fill(255);
      pg.stroke(255);
    } else {
      pg.fill(0);
      pg.stroke(0);
    }
    pg.strokeWeight(sw);
    pg.pushMatrix();
    pg.translate(x, y);
    float ang = 0;
    for (int i = 0; i < kumo; i++) {
      float rad = radians(ang);
      float x2 = 0 + (radius*0.25*cos(rad));
      float y2 = 0 + (radius*0.25*sin(rad));
      float rad2 = radius*0.5;
      pg.ellipse(x2, y2, rad2, rad2);
      ang += addAng;
    }
    pg.popMatrix();
  }

  void maru2(int x, int y, int rad) {
    if (myc2 == color(0)) {
      pg.fill(255);
      pg.stroke(255);
    } else {
      pg.fill(0);
      pg.stroke(255);
    }
    pg.strokeWeight(sw);
    pg.ellipse(x, y, rad*0.5, rad*0.5);
  }

  void drawTwinkleStar2(int x, int y, int radius) { //+
    if (myc2 == color(0)) {
      pg.fill(255);
      pg.stroke(255);
    } else {
      pg.fill(0);
      pg.stroke(255);
    }
    pg.pushMatrix();
    pg.translate(x, y);
    pg.beginShape();
    for (int theta = 0; theta < 360; theta++) {
      pg.vertex(radius*0.35 * pow(cos(radians(theta)), 3), radius*0.35 * 1.4 * pow(sin(radians(theta)), 3));
    }
    pg.endShape(CLOSE);
    pg.popMatrix();
  }

  void twinkle2(int x, int y, int radius, int nPoints) {
    float angle = TWO_PI / nPoints;
    float angle2 = angle / 2;
    float origAngle = 0.0;
    float rad1 = radius/2*0.95;
    float rad2 = rad1/4;

    pg.pushMatrix();
    pg.translate(x, y);
    pg.rotate(ro);
    if (myc2 == color(0)) {
      pg.fill(0);
    } else {
      pg.fill(255);
    }
    pg.noStroke();
    pg.ellipse(0, 0, radius, radius);
    if (myc2 == color(0)) {
      pg.fill(255);
      pg.stroke(255);
    } else {
      pg.fill(0);
      pg.stroke(0);
    }
    pg.strokeWeight(sw);
    pg.strokeJoin(ROUND);
    pg.beginShape();
    for (int i = 0; i < nPoints; i++)
    {
      float y1 = rad1 * sin(origAngle);
      float x1 = rad1 * cos(origAngle);
      float y2 = rad2 * sin(origAngle + angle2);
      float x2 = rad2 * cos(origAngle + angle2);
      pg.vertex(x1, y1);
      pg.vertex(x2, y2);
      origAngle += angle;
    }
    pg.endShape(CLOSE);
    pg.popMatrix();
  }

  void star2(int x, int y, int radius) {
    float size = float(radius)*0.89;

    pg.pushMatrix();
    pg.translate(x, y);
    if (myc2 == color(0)) {
      pg.fill(255);
      pg.stroke(255);
    } else {
      pg.fill(0);
      pg.stroke(0);
    }
    pg.strokeWeight(sw);
    pg.rotate(ro);
    pg.beginShape();
    pg.vertex(-0.089*size, -0.4204*size);
    pg.bezierVertex(-0.0404*size, -0.5187*size, 0.0388*size, -0.5187*size, 0.0874*size, -0.4204*size);
    pg.vertex(0.1754*size, -0.2221*size);
    pg.vertex(0.3724*size, -0.2136*size);
    pg.bezierVertex(0.4806*size, -0.1977*size, 0.5051*size, -0.1224*size, 0.4267*size, -0.046*size);
    pg.vertex(0.2842*size, 0.093*size);
    pg.vertex(0.3179*size, 0.2891*size);
    pg.bezierVertex(0.3363*size, 0.397*size, 0.2722*size, 0.4436*size, 0.1753*size, 0.3926*size);
    pg.vertex(-0.0008*size, 0.3*size);
    pg.vertex(-0.1769*size, 0.3926*size);
    pg.bezierVertex(-0.2738*size, 0.4436*size, -0.3379*size, 0.397*size, -0.3195*size, 0.2891*size);
    pg.vertex(-0.2858*size, 0.093*size);
    pg.vertex(-0.4283*size, -0.046*size);
    pg.bezierVertex(-0.5067*size, -0.1224*size, -0.4822*size, -0.1978*size, -0.3739*size, -0.2135*size);
    pg.vertex(-0.177*size, -0.2421*size);
    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}
