/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

float wplace = 500.0, hplace= 500.0;
float wgalery = (wplace/2.0) * 0.7, hgalery = (hplace/2.0) * 0.7;
float raio_sensor = wgalery * 1.1;
float raio_indicador = 10;


/*
  A codificação será o mais próxima da encontrada no arduíno
*/
ArrayList<sensor> sensores = new ArrayList<sensor>();
ArrayList<atuador> atuadores = new ArrayList<atuador>();

boolean mouse_action = true, flag_collect = false, flag_rota = false;

float[] buffer_entrada = {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};

float limiar_baixo = 6.75;
//limiar de sensores é a quantidade minima de sensores necessária com fumaça para traçar uma rota de fuga
int limiar_sensores = 5;

int framerate = 60;

int num_sensores = 8, num_atuadores = 12;
int pos_start_atuador = 1, pos_end_atuador = 8;

color sensor_color = color(0);
color red = color(255,0,0);
color green = color(0,255,0);
color saida = color(255);
color not_use_space = color(102);
color start = green;


int start_route = 9, end_route = 0;

color[] atuadores_color = {not_use_space, green, green, green, green, green, green, green, green, green, green, green, start, saida};

//DISPOSIÇÃO DOS SENSORES
int w_planta_sensores = 7, h_planta_sensores = 7;
int[][] disposicao_sensores = 
  {
    {1,  1,  1,  13,  2,  2,   2},
    {1,  0,  0,   5,  0,  0,   2},
    {1,  0,  0,   5,  0,  0,   2},
    {9, 8,  8,  10,  6,  6,  11},
    {4,  0,  0,   7,  0,  0,   3},
    {4,  0,  0,   7,  0,  0,   3},
    {4,  4,  4,   12,  3,  3,   3}    
  };
  
  //PONTOS DE ENCONTRO ENTRE ATUADORES
  int qtd_pontos_encontro = 3; 
  int start_pontos_encontro = 2;
  //quantidade de elementos, atuador, sensor, ..., sensor
  int[][] pontos_encontro_atuadores = {
    {3, 9, 1, 8, 4},
    {3, 11, 2, 3, 6},
    {4, 10, 5, 6, 7, 8}
  };
 
 
 //ATUADORES LIGADOS AOS SENSORES
 int delimitador = 3; 
 //primeira coluna é o numero de atuadores respectivos de cada sensor
 //cada linha representa um dos sensores
  int[][] atuadores_linked_sensores = 
  {
    {1, 0},
    {1, 1},
    {1, 2},
    {1, 3},
    {1, 4},
    {1, 5},
    {1, 6},
    {1, 7},
    {1, 8},
    {1, 9},
    {1,10},
    {1,11}
  };
 
 
 //MATRIZ DE ADJACENCIA
 int tam_matriz_adj = 10;
 //a primeira e a ultima linha são o inicio e fim da rota sempre
 int[][] matriz_adjacencia = {
    {0,  1,  1,  0,  0,  1,  0,  0,  0,  0},
    {1,  0,  0,  0,  1,  0,  0,  0,  1,  0},
    {1,  0,  0,  1,  0,  0,  1,  0,  0,  0},
    {0,  0,  1,  0,  0,  0,  1,  0,  0,  1},
    {0,  1,  0,  0,  0,  0,  0,  0,  1,  1},
    {1,  0,  0,  0,  0,  0,  1,  1,  1,  0},
    {0,  0,  1,  1,  0,  1,  0,  1,  1,  0},
    {0,  0,  0,  0,  0,  1,  1,  0,  1,  1},
    {0,  1,  0,  0,  1,  1,  1,  1,  0,  0},
    {0,  0,  0,  1,  1,  0,  0,  1,  0,  0}
 };
 
