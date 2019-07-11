/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

void collect_data_arduino(){
   //coleta dados do arduino
  for(int i = 1; i <= 8; i++){
    buffer_entrada[i] = random(1, 50);
  }
}
