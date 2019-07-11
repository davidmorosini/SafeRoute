/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

class sensor{
  float x, y, r;
  color c;
  float raio_sensor;
  boolean raio_ativo;
  int id;
  
  float value;
  
  ArrayList<atuador> atuadores;
  
  sensor(float x, float y, float r, float raio_sensor, color c, int id){
    this.x = x;
    this.y = y;
    this.r = r;
    this.c = c;  
    this.raio_sensor = raio_sensor;
    this.id = id;
    value = 0.0;
  }
  
  void raio_on_off(){
     raio_ativo = !raio_ativo;
  }
  
  void collect(float[] buffer, boolean onBuffer){
    value = 0.0;
    if(onBuffer){
      value = buffer[id];
    }else{
      float dist = sqrt((x - mouseX)*(x - mouseX) + (y - mouseY)*(y - mouseY));
      if(dist <= raio_sensor/2.0){
        value = (raio_sensor/2.0) - dist;
      }
    }
  }

  void display(){
    
    //desenhar o raio de atuação do sensor
    if(raio_ativo){
      pushMatrix();
        noFill();
        stroke(0,0,255);
        translate(x, y);
        ellipse(0, 0, raio_sensor, raio_sensor);
      popMatrix();
    }
    
    pushMatrix();
      fill(c);
      stroke(c);
      translate(x, y);
      ellipse(0, 0, r, r);
    popMatrix();
  }
    
}
