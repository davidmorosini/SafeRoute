/*
  Autor: David Morosini de Assumpção
  INterfaces e Periféricos 2018/2
*/

float INFINITY = 32768.0;
int MEMBER = 1;
int NONMEMBER = 0;
int MAXNODES = 10;

class node{
  int adj;
  float peso;
  
  node(int adj, float peso){
    this.adj = adj;
    this.peso = peso;
  }
}



node[][] GRAPH;


int[] calcula_rota(int init, int fim, int[][] adjs, float[] pesos){
   
  float[][] m = monta_matriz_pesos(pesos);
    
  init_graph(adjs, m);
  
  
  int[] path = dijkstra(init, fim);
  
  return path;
}

void init_graph(int[][] adjs, float[][] pesos){
  GRAPH = new node[MAXNODES][MAXNODES];
  
  
  for(int i = 0; i < MAXNODES; i++){
    for(int j = 0; j < MAXNODES; j++){
      float peso = INFINITY;
      int a = adjs[i][j];
      if(a == 1){
        peso = pesos[i][j];
      }
      
      GRAPH[i][j] = new node(a, peso); 
    }
  }  
}

float[][] monta_matriz_pesos(float[] l){
  float[][] m = new float[MAXNODES][MAXNODES];
  
  for(int i = 0; i < MAXNODES; i++){
    for(int j = 0; j < MAXNODES; j++){
      if(matriz_adjacencia[i][j] == 1){
        //a soma dos valores medidos pelos sensores é o peso do caminho
        m[i][j] = l[i]  + l[j];
        
      }else{
        m[i][j] = 0.0;
      }
    }
  } 
 
  return m;
}


int[] dijkstra(int s, int t){
   int[] perm = new int[MAXNODES], path = new int[MAXNODES];
   float[] dist = new float[MAXNODES];
   
   int current, i, k;
   float smalldist, newdist, dc;
      
   for(i = 0; i < MAXNODES; i++){
     perm[i] = NONMEMBER;
     dist[i] = INFINITY;
   }
   
   perm[s] = MEMBER;
   dist[s] = 0.0;
   
   //originando a busca
   current = s;
   k = current;

   while(current != t){
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
   
   
   //println("CAMINHO: ");
   int[] route = new int[MAXNODES];
   int caminho = t;
   route[0] = t;
   //print(t + " <-");
   int cont = 1;
   while(caminho != s){
       
       route[cont] = path[caminho];
       //print(route[cont]);
       
       cont++;
       
       caminho = path[caminho];

       //if (caminho != s)
           //print(" <- ");
   }
   
   //print("\n");
      
   return route;
}
