/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

class atuador{
  float x, y, r;
  color c;
  
  atuador(float x, float y, float r, color c){
    this.x = x;
    this.y = y;
    this.r = r;
    this.c = c;
  }
  
  void set_color(color c){
    this.c = c;
  }
   
  
  void display(){   
     pushMatrix();
       translate(x, y);
       stroke(c);
       fill(c);
       ellipse(0,0,r,r);
     popMatrix();
  }
   

}
