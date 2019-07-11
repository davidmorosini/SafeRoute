/**
  Autores: David Morosini de Assumpção, Amanda Oliosi
  Trabalho de Interfaces e Peridéricos 2018/2
*/


#define MEMBER 1
#define NONMEMBER 0
#define MAXNODES 7

//vamos considerar 1 led, como 1 par de leds
#define NUM_LEDS 5
#define NUM_SENSORES 5
#define NUM_SENSORES_REAIS 1

#define ON 1.0
#define OFF 0.0


typedef struct graph{
  int adj;
  float peso;
}graph;

typedef struct no{
  int valor;
  struct no * prox, * ant;
}no;

typedef struct tower{
  int qtd;
  no * start, * end;
}tower;

typedef struct PAR_LED{
  //representa cada par de leds, com suas portas e valores
  int porta_r, porta_g;
  float valor_r, valor_g;
}led;


/*
  ESQUEMÁTICO DA DISPOSIÇÃO DOS SENSORES E A COMUNICAÇÃO ENTRE OS CAMINHOS

  Por exemplo, o sensor 1 forma um caminho com 0, 4, 5

  1-----0-----2    
  |     |     |
  |     |     |
  |-----5-----|
  |     |     |
  |     |     |
  4-----6-----3    

  NOTE QUE O SENSOR 0 e 6, NÃO CONSTAN NO PROJETO FÍSICO, ELES SÃO VIRTUAIS
  E EXPRESSA O INÍCIO E FINAL DA ROTA (SAÍDA), RESPECTIVAMENTE. NÃO SE PREOCUPE COM ELE
  EM RELAÇÃO A ELETRÔNICA.
*/


//Matriz de adjacencia dos leds (REPRESENTA ESSES CAMINHOS DESCRITOS ACIMA)
int matriz_adj[][7] =  {{0,  1,  1,  0,  0,  0,  0},
                        {1,  0,  0,  0,  1,  1,  0},
                        {1,  0,  0,  1,  0,  1,  0},
                        {0,  0,  1,  0,  0,  1,  1},
                        {0,  1,  0,  0,  0,  1,  1},
                        {0,  1,  1,  1,  1,  0,  0},
                        {0,  0,  0,  1,  1,  0,  0}};

//BUFFER PARA ARMAZENAR OS VALORES DOS SENSORES
float buffer_sensores[7] = {0.0,0.0,0.0,0.0,0.0,0.0,0.0};

led leds[NUM_LEDS];
//só temos um sensor de fato..

//note que estes dois itens (start_route e end_route) são os sensores virtuais mencionados,
//a estratégia para escolher estes, pode ser alterada de acordo com as características do layout
int end_route = 0, start_route = 6;
float limiar_fumaca = 1.0;
int limiar_sensores = 1;


// Definicoes dos pinos ligados ao sensor 
int pin_d0 = 13;
int pin_a0 = A0;
int nivel_sensor = 80;

//MÉTODOS INTERNOS
/*Método utilizado para calcular a rota, inicio e fim da rota são as entradas (9 e 0)*/
tower * calcula_rota(int start, int end);
tower * init_tower();
void add_node(tower * t, int valor);


//MÉTODOS DE AÇÃO NO ARDUINO
//Marca todos os leds como vermelho e após, marca os verdes de acordo com o caminho
void reseta_leds(tower * t);
//Busca as informações do sensor (no nosso caso, pega uma informação e "cria as outras 7")
void coleta_dados_sensor();
//Apaga todos os leds
void apaga_leds();
//Aualiza leds
void atualiza_leds();




/*#################################################################################*/


void setup() {

   Serial.begin(9600);   
   
   // Define os pinos de leitura do sensor como entrada
  pinMode(pin_d0, INPUT);
  pinMode(pin_a0, INPUT);

 
   leds[0].porta_r = 5;
   leds[0].porta_g = 4;
   leds[1].porta_r = 11;
   leds[1].porta_g = 10;
   leds[2].porta_r = 9;
   leds[2].porta_g = 8;
   leds[3].porta_r = 3;
   leds[3].porta_g = 2;
   leds[4].porta_r = 7;
   leds[4].porta_g = 6;

   int i;
   for(i = 0; i < NUM_LEDS; i++){
    pinMode(led[i].porta_g, OUTPUT);
    pinMode(led[i].porta_r, OUTPUT);
   }
    
}

void loop() {

 //Coletar dados dos sensores
  coleta_dados_sensor();
  

  //verificar se existe uma quantidade alarmante de sensores com fumaça
  int i, qtd_sensores = 0;
  for(i = 1; i <= NUM_SENSORES; i++){
    if(buffer_sensores[i] >= limiar_fumaca){
      qtd_sensores++;
    }
  }


  //caso tenhamos uma quantidade expressiva de sensores
  //detectando fumaça, vamos calcular a rota
  if(qtd_sensores >= limiar_sensores){
    
    int start = 6;
    //seleciona o menor dos 3 sensores de baixo
        
    tower * t = calcula_rota(start, end_route);

    //reseta_leds vai setar como HIGH somente os leds verdes que formam o caminho e os demais vermelhos
    reseta_leds(t);
    
    free(t);

  }else{
    //apaga todos os leds
    apaga_leds();
  }

  //da o comando para o arduino atualizar os LEDs de fato
  atualiza_leds();


  //delay da aplicação
  delay(2000);
  
  
}


/*##################  ARDUINO #####################*/
void atualiza_leds(){
  int i;
  for(i = 0; i < 5; i++){
    digitalWrite(leds[i].porta_r, leds[i].valor_r);
    digitalWrite(leds[i].porta_g, leds[i].valor_g);
  }
  
}

void apaga_leds(){
  int i;
  for(i = 0; i < NUM_LEDS; i++){
    leds[i].valor_r = LOW;
    leds[i].valor_g = LOW;
  }
}

void reseta_leds(tower * t){
  int i;
  for(i = 0; i < NUM_LEDS; i++){
    (leds[i]).valor_r = HIGH;
    (leds[i]).valor_g = LOW;
  }

  //O último elemento da torre é o led virtual 9 e o primeiro é o 0,
  //Logo temos que percorrer entre o segundo elemento e o penúltimo
  //a posição do led, é sempre o da torre menos um


  no * n = (t -> start) -> prox;
  for(i = 1; i < (t -> qtd); i++){
    int aux = (n -> valor) - 1;
    leds[aux].valor_g = HIGH;
    leds[aux].valor_r = LOW;
    n = n -> prox;
  }

}



void coleta_dados_sensor(){
  //[AQUI] Coletar os dados do sensor
  //float aux = (float(analogRead(porta_sensor))*5/(1023))/0.01;
  
  int valor_digital = digitalRead(pin_d0);
  // Le os dados do pino analogico A0 do sensor
  int valor_analogico = analogRead(pin_a0);
  // Mostra os dados no serial monitor
  
  float aux = (float)valor_analogico;
  
  buffer_sensores[1] = aux;

  //[AQUI] Criar dados virtuais para os outros 7 sensores
  int i;
  for(i = 2; i <= NUM_SENSORES; i++){
    float r = random(aux*0.1, aux * 1.9);
    buffer_sensores[i] = r;
  }

  //[AQUI] Salvar os dados no buffer_sensores,
  //lembrando que a posição 0  deste buffer 
  //é dedicada ao "leds/sensor virtuais"
  //logo não deve ser modificada
  //logo, apenas colocar os valores entre a posição 2 e 8 do vetor, visto que a 1 é a do sensor real

}

/*##################  ARDUINO #####################*/

tower * init_tower(){
  tower * t = (tower *)malloc(sizeof(tower));
  t -> qtd = 0;
  t -> start = NULL;
  t -> end = NULL;
  return t;
}


void add_node(tower * t, int valor){
  if(t != NULL){
    no * n = (no *)malloc(sizeof(no));
    n -> valor = valor;
    n -> prox = NULL;
    n -> ant = NULL;

    if(t -> qtd == 0){
      t -> start = n;
    }else{
      n -> ant = t -> end;
      (t -> end) -> prox = n;
    }
    t -> end = n;
    (t -> qtd)++;
  }
}

tower * calcula_rota(int start, int end){
  tower * t = init_tower();

  graph GRAPH[MAXNODES][MAXNODES];
  float pesos[MAXNODES][MAXNODES];

  int i, j, k, current;
  float dist[MAXNODES];
  int perm[MAXNODES], path[MAXNODES];
  float smalldist, newdist, dc;


  //monta matriz de pesos
  for(i = 0; i < MAXNODES; i++){
    for(j = 0; j < MAXNODES; j++){
      if(matriz_adj[i][j] == 1){
        //a soma dos buffer_sensores medidos pelos sensores é o peso do caminho
        pesos[i][j] = buffer_sensores[i]  + buffer_sensores[j];
      }else{
        pesos[i][j] = 0.0;
      }

      //após inicializada, vamos iniciar o grafo
      float peso = INFINITY;
      int ad = matriz_adj[i][j];
      if(ad == 1){
        peso = pesos[i][j];
      }

      GRAPH[i][j].adj = ad;
      GRAPH[i][j].peso = peso;

    }
  }  
  
 
  for(i = 0; i < MAXNODES; i++){
     perm[i] = NONMEMBER;
     dist[i] = INFINITY;
  }
   
  perm[start] = MEMBER;
  dist[start] = 0.0;
 
  //originando a busca
  current = start;
  k = current;

  while(current != end){
    smalldist = INFINITY;
    dc = dist[current];
   
    for(i = 0; i < MAXNODES; i++){
      if(perm[i] == NONMEMBER){
        newdist = dc + GRAPH[current][i].peso;
       
        if(newdist < dist[i]){
          dist[i] = newdist;
          path[i] = current;
        }
       
        if(dist[i] < smalldist){
          smalldist = dist[i];
          k = i;
        }
      }
    }
    current = k;
    perm[current] = MEMBER;
  }
   
   
   int route[MAXNODES];
   int caminho = end;
   add_node(t, caminho);
   route[0] = end;
   int cont = 1;
   while(caminho != start){
      route[cont] = path[caminho];
      cont++;
      caminho = path[caminho];
      add_node(t, caminho);
   }

  return t;
}
