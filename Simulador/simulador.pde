/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

/**
  Manual:
   Press c para habilitar a coleta automática.
   Press m para alterar o modo de coleta.
   Press d para habilitar o raio dos sensores.
   Press [1 - 8] para setar manualmente cada sensor.   
*/


void setup() {
  size(1000, 600);
  frameRate(framerate);
  
  create_sensor_atuador();
}



void draw() {
  background(67);
    
  if(!mouse_action && flag_collect){
     delay(2500); 
   }
   
  //Arduino 
  collect_data_arduino();
  
  //verifica valores
  
  //caso necessário calcula rota
  
  //Exibe
  display();
}

void keyPressed() {
 
  if(key == 'd'){
    for(int i = 0; i < sensores.size(); i++){
      sensores.get(i).raio_on_off();
      
    }
  }else if(key == 'c'){
    flag_collect = !flag_collect;
  }
  else if(key == 'm'){
    mouse_action = !mouse_action;
  }
  
  int tecla = key;
  tecla -= 48;
  if(tecla >= 1 && tecla <= 8){
    flag_collect = false;
    float s_value = sensores.get(tecla - 1).value;
    if(s_value > 0){
      sensores.get(tecla - 1).value = 0.0;
    }else{
      sensores.get(tecla - 1).value = random(1, 50);
    }
  }
    
}


void display(){
  
  show_place();
  
 int sensores_com_fumaca = 0;
  
  for(int i = 0; i < sensores.size(); i++){
    if(flag_collect){
      sensores.get(i).collect(buffer_entrada, !mouse_action);
    }
    
    float vaux = sensores.get(i).value;
     
    if(vaux < limiar_baixo){
        atuadores_color[i+1] = green;
    }else{
        atuadores_color[i+1] = red;
        sensores_com_fumaca++;
    }
    
    sensores.get(i).display();
  }
  

  flag_rota = false; 
  if(sensores_com_fumaca >= limiar_sensores){
        
     flag_rota = true;
     int[] rota = calcula_rota(start_route, end_route, matriz_adjacencia, buffer_entrada);
     
     for(int i = 1; i <= sensores.size(); i++){
       atuadores_color[i] = red;
     }
         
       
      boolean sair = false;
      for(int i = 1; i < tam_matriz_adj && !sair; i++){
        if(rota[i] != start_route){
          atuadores_color[rota[i]] = green;
          atuadores.get(atuadores_linked_sensores[rota[i] - 1][0]).set_color(atuadores_color[rota[i]]);
          if(rota[i] - 1 > delimitador){
            atuadores.get(atuadores_linked_sensores[rota[i] - 1][1]).set_color(atuadores_color[rota[i]]);
          }
                  
        }else{
          sair = true;
        }
      }    
  }
  
  for(int i = 0; i < qtd_pontos_encontro; i++){
    int cont = 0;
    for(int j = start_pontos_encontro; j < pontos_encontro_atuadores[i][0] + start_pontos_encontro; j++){
      if(atuadores_color[pontos_encontro_atuadores[i][j]] == green){
        cont++;
      }
    }
    if(cont > 1){
      atuadores_color[pontos_encontro_atuadores[i][1]] = green;
    }else{
      atuadores_color[pontos_encontro_atuadores[i][1]] = red;
    }
  }
  
  for(int i = 0; i < atuadores.size(); i++){
      atuadores.get(i).set_color(atuadores_color[i + 1]);
      if(i >= sensores.size()){
         atuadores.get(i).set_color(atuadores_color[i + 1]);

      }
      atuadores.get(i).display();
  }
   
  
  show_infs();
  show_matrix();
  
}


void show_place(){
  rectMode(CENTER);
  //quadrado referente ao local
  fill(255);
  stroke(255);
  rect(width/2.0,height/2.0,wplace,hplace);
  //neste exemplo teremos 4 galerias internas
  //imagine o quadrado em 4 quadrantes, uma 
  //galeria ema cada quadrante
  
  
  fill(153);
  stroke(153);
  rect((width/2.0) - (wplace/4.0), (height/2.0) - (hplace/4.0), wgalery, hgalery);
  rect((width/2.0) + (wplace/4.0), (height/2.0) - (hplace/4.0), wgalery, hgalery);
  rect((width/2.0) - (wplace/4.0), (height/2.0) + (hplace/4.0), wgalery, hgalery);
  rect((width/2.0) + (wplace/4.0), (height/2.0) + (hplace/4.0), wgalery, hgalery);
  
  pushMatrix();
    translate((width/2.0) - 10, (height/2.0) - (hplace/2.0));
    rectMode(CENTER);
    fill(255, 0, 0);
    stroke(255, 0, 0);
    rect(8, -3, 50, 20);
    fill(255);
    text("SAIDA", -10, 1);
  popMatrix();
 
}


void show_matrix(){
    rectMode(CENTER);
    stroke(0);
    int lado = 25;
    
    pushMatrix();
    translate(width/2.0 - wplace/2.0 - 130, height/2.0);
    for(int i = 0, k = -(w_planta_sensores/2); i < w_planta_sensores; i++, k++){
      for(int j = 0, l = -(h_planta_sensores/2); j < h_planta_sensores; j++, l++){
        fill(atuadores_color[disposicao_sensores[i][j]]);
        rect(l * lado, k * lado, lado, lado);
      }
    }
   popMatrix();
}

void show_infs(){
    fill(255);
    stroke(0);
    rect(width/2.0 + wplace/2.0 + 130, height/2.0, 200, hplace/2.0);
    
    fill(0);
    int qtd = sensores.size() / 2;
    text("Coleta Automática = " + (flag_collect ? "ON":"OFF"), width/2.0 + wplace/2.0 + 40, height/2.0 + 15 * (-qtd - 2));
    
    for(int i = 0, j = -qtd; i < sensores.size(); i++, j++){
      text("Sensor [ " + sensores.get(i).id + " ] = " + sensores.get(i).value + " ppm", width/2.0 + wplace/2.0 + 40, height/2.0 + 15 * j);
    }
    
    text("Calculando rota = " + (flag_rota ? "ON":"OFF"), width/2.0 + wplace/2.0 + 40, height/2.0 + 15 * (qtd + 2));

}

void create_sensor_atuador(){
  //Sensor Do canto superior esquerdo
  sensores.add(new sensor((width/2.0) - wplace/2.0 + 40, (height/2.0) - (hplace/2.0) + 40,10,raio_sensor,sensor_color, 1));
  atuadores.add(new atuador((width/2.0) - wplace/2.0 + 20, (height/2.0) - (hplace/2.0) + 20, raio_indicador, green));

  sensores.add(new sensor((width/2.0) + wplace/2.0 - 40, (height/2.0) - (hplace/2.0) + 40,10,raio_sensor,sensor_color, 2));
  atuadores.add(new atuador((width/2.0) + wplace/2.0 - 20, (height/2.0) - (hplace/2.0) + 20, raio_indicador, green));
  
  sensores.add(new sensor((width/2.0) + wplace/2.0 - 40, (height/2.0) + (hplace/2.0) - 40,10,raio_sensor,sensor_color, 3));
  atuadores.add(new atuador((width/2.0) + wplace/2.0 - 20, (height/2.0) + (hplace/2.0) - 20, raio_indicador, green));

  sensores.add(new sensor((width/2.0) - wplace/2.0 + 40, (height/2.0) + (hplace/2.0) - 40,10,raio_sensor,sensor_color, 4));
  atuadores.add(new atuador((width/2.0) - wplace/2.0 + 20, (height/2.0) + (hplace/2.0) - 20, raio_indicador, green));
  
  sensores.add(new sensor((width/2.0), (height/2.0) - (hplace/4.0),10,raio_sensor,sensor_color, 5));
  atuadores.add(new atuador((width/2.0), (height/2.0) - (hplace/4.0), raio_indicador, green));
  
  sensores.add(new sensor((width/2.0) + (wplace/4.0), (height/2.0),10,raio_sensor,sensor_color, 6));
  atuadores.add(new atuador((width/2.0) + (wplace/4.0), (height/2.0), raio_indicador, green));
  
  sensores.add(new sensor((width/2.0), (height/2.0) + (hplace/4.0),10,raio_sensor,sensor_color, 7));
  atuadores.add(new atuador((width/2.0), (height/2.0) + (hplace/4.0), raio_indicador, green));
  
  sensores.add(new sensor((width/2.0) - (wplace/4.0), (height/2.0),10,raio_sensor,sensor_color, 8));
  atuadores.add(new atuador((width/2.0) - (wplace/4.0), (height/2.0), raio_indicador, green));
  
  
  atuadores.add(new atuador((width/2.0) - (wplace/2.0) + 20, (height/2.0), raio_indicador, green));
  atuadores.add(new atuador((width/2.0), (height/2.0), raio_indicador, green));
  atuadores.add(new atuador((width/2.0) + (wplace/2.0) - 20, (height/2.0), raio_indicador, green)); 
  atuadores.add(new atuador((width/2.0), (height/2.0) + (wplace/2.0) - 20, raio_indicador, green));

}
