import java.util.*;
import java.lang.Math;

static int cellSize = 15;
Game g = new Game(34);

int rectColor;
int rectSize = 90;
color rectHighlight;
int rectX;
int rectY;
boolean rectOver;
boolean start = false;
boolean gameOver;

void setup(){
  size(510,510);
  frameRate(10);
  
  rectColor = color(226,205,177);
  rectSize = 90;
  rectX = (width/2)-rectSize;
  rectY = (width/2)-rectSize;
  gameOver = false;
  ellipseMode(CENTER);
}


void draw(){
  background(200);
  update(mouseX, mouseY);
  if(start && !gameOver){
    stroke(0);
    g.display();
  }
  else if(!start && !gameOver){
     fill(rectColor);
     rect(rectX, rectY+20, rectSize*2, rectSize);
     textSize(50);
     fill(0,102,153);
     text("Start", rectX+(rectX/5), rectY+80);
  }
  else{ // !start && gameOver
      g.restart();
  }
}

void update(int x, int y){
   if(overRect(rectX, rectY+20, rectSize*2, rectSize)){
      rectOver = true;
      if(gameOver){
        g = new Game(34);
      }
   }
   else{
      rectOver = false; 
   }
}

boolean overRect(int x, int y, int width, int height){
   if(mouseX >= x && mouseY <= x+width && 
      mouseY >= y && mouseY <= y+height){
     return true;
   }
   else{
     return false;
   }
}

void keyPressed(){
  if(!start){
     if(keyPressed){
        if(key == ' '){
           start = true; 
        }
     }
  }
  
  if(!start && gameOver){
    if(keyPressed){
        if(key == ' '){
          start = true;
          gameOver = false;
        }
    }
  }
   if(key == CODED){
      if(keyCode == UP){
        System.out.println("Up");
        if(start){g.moveUp();}
      }
      else if(keyCode == RIGHT){
        System.out.println("Right");
        if(start){g.moveRight();}
      }
      else if(keyCode == DOWN){
        System.out.println("Down");
        if(start){g.moveDown();}
      }
      else if(keyCode == LEFT){
        System.out.println("Left");
        if(start){g.moveLeft();}
      }
   }
}

void mousePressed(){
   if(rectOver){start=true;}
   if(gameOver && rectOver){
     start = true;
     gameOver = false;
   }
}

public class Game{
   private int size;
   private ArrayList<Cell> snake;
   private Cell[][] grid;
   private int gridSize;
   private Random rng;
   private int numToAdd;
   
   public Game(int boardSize){
      size = 5;
      snake = new ArrayList<Cell>();
      gridSize = boardSize;
      if(boardSize<10){
       gridSize = 20; 
      }
      grid = new Cell[gridSize][gridSize];
      for(int i=0; i<gridSize; i++){
        for(int j=0; j<gridSize; j++){
           grid[i][j] = new Cell(j,i);   
        }
      }
      rng = new Random();
      
      for(int i = gridSize/2; i<(gridSize/2)+5; i++){
         snake.add(grid[i][gridSize/2]); 
         grid[i][gridSize/2].editSnake(true);
         grid[i][gridSize/2].changeDirection(1);
      }
      this.spawnFood();
      this.snake.get(0).changeDirection(1);
      numToAdd = 0;
   }
   
   public void display(){
      for(int i=0; i<gridSize; i++){
        for(int j=0; j<gridSize; j++){
           Cell c = grid[i][j];
           if(c.isSnake){
             fill(0,255,0);
             rect(j*cellSize, i*cellSize, cellSize, cellSize);
           }
           else if(c.isFood()){
               fill(255,0,0);
               rect(j*cellSize, i*cellSize, cellSize, cellSize);
           }
           
        }
      }
      if(!gameOver){
        this.move();
        this.checkHead();
      }
   }
   
   public void restart(){
     fill(rectColor);
     rect(rectX, rectY+20, rectSize*2, rectSize);
     textSize(50);
     fill(0,102,153);
     text("Retry?", rectX+(rectX/8), rectY+80); 
   }
   
   public int getSize(){return this.size;}
   public void spawnFood(){
    int count = 0;
    int foodX = 0;
    int foodY = 0;
    while(count<1){
     count++;
     foodX = rng.nextInt(gridSize);
     foodY = rng.nextInt(gridSize);
     for(Cell c:snake){
       if((c.getX()==foodX)&&(c.getY()==foodY)){
         count = 0;
         break;
       }
     }
    }
    this.grid[foodY][foodX].editFood(true);
   }
   public void move(){
      Cell head = this.snake.get(0);
      int headX = head.getX();
      int headY = head.getY();
      if(numToAdd>0){
        try{
          if(head.getDirection()==1){
           //Move up
           Cell newHead = grid[headY-1][headX];
           if(newHead.isSnake()){
             this.gameOver();
             return;
           }
           snake.add(0,newHead);
           newHead.editSnake(true);
           newHead.changeDirection(head.getDirection());
           numToAdd--;
          }
          else if(head.getDirection()==2){
           //Move right
           Cell newHead = grid[headY][headX+1];
           if(newHead.isSnake()){
             this.gameOver();
             return;
           }
           snake.add(0,newHead);
           newHead.editSnake(true);
           newHead.changeDirection(head.getDirection());
           numToAdd--;
          }
          else if(head.getDirection()==3){
           //Move down
           Cell newHead = grid[headY+1][headX];
           if(newHead.isSnake()){
             this.gameOver();
             return;
           }
           snake.add(0,newHead);
           newHead.editSnake(true);
           newHead.changeDirection(head.getDirection());
           numToAdd--;
          }
          else{
           //Move left
           Cell newHead = grid[headY][headX-1];
           if(newHead.isSnake()){
             this.gameOver();
             return;
           }
           snake.add(0,newHead);
           newHead.editSnake(true);
           newHead.changeDirection(head.getDirection());
           numToAdd--;
          }
        } catch(ArrayIndexOutOfBoundsException E){
          this.gameOver();
        }
      }
      else{
          try{
            if(head.getDirection()==1){
             //Move up
             Cell tail = snake.remove(snake.size()-1);
             tail.editSnake(false);
             Cell newHead = grid[headY-1][headX];
             if(newHead.isSnake()){
               this.gameOver();
               return;
             }
             snake.add(0,newHead);
             newHead.editSnake(true);
             newHead.changeDirection(head.getDirection());
            }
            else if(head.getDirection()==2){
             //Move right 
             Cell tail = snake.remove(snake.size()-1);
             tail.editSnake(false);
             Cell newHead = grid[headY][headX+1];
             if(newHead.isSnake()){
               this.gameOver();
               return;
             }
             snake.add(0,newHead);
             newHead.editSnake(true);
             newHead.changeDirection(head.getDirection());
            }
            else if(head.getDirection()==3){
             //Move down
             Cell tail = snake.remove(snake.size()-1);
             tail.editSnake(false);
             Cell newHead = grid[headY+1][headX];
             if(newHead.isSnake()){
               this.gameOver();
               return;
             }
             snake.add(0,newHead);
             newHead.editSnake(true);
             newHead.changeDirection(head.getDirection());
            }
            else{
             //Move left
             Cell tail = snake.remove(snake.size()-1);
             tail.editSnake(false);
             Cell newHead = grid[headY][headX-1];
             if(newHead.isSnake()){
               this.gameOver();
               return;
             }
             snake.add(0,newHead);
             newHead.editSnake(true);
             newHead.changeDirection(head.getDirection());
            }
          } catch(ArrayIndexOutOfBoundsException E){
            this.gameOver();
          }
      }
   }
   
   public void checkHead(){
      Cell c = this.snake.get(0);
      if(c.isFood()){
         numToAdd = 5;
         this.spawnFood();
         c.editFood(false);
      }
   }
   
   public void moveUp(){
     System.out.println("up");
      if(this.snake.get(0).getDirection()==3){
        this.gameOver();
      }
      else{
        this.snake.get(0).changeDirection(1);
      }
   }
   
   public void moveRight(){
     System.out.println("right");
      if(this.snake.get(0).getDirection()==4){
        this.gameOver();
      }
      else{
        this.snake.get(0).changeDirection(2);
      }
   }
   
   public void moveDown(){
     System.out.println("down");
      if(this.snake.get(0).getDirection()==1){
        this.gameOver();
      }
      else{
        this.snake.get(0).changeDirection(3);
      }
   }
   
   public void moveLeft(){
     System.out.println("left");
      if(this.snake.get(0).getDirection()==2){
        this.gameOver();
      }
      else{
        this.snake.get(0).changeDirection(4);
      }
   }
   public void gameOver(){
     System.out.print("Game Over");
     gameOver = true;
     start = false;
   }
}

public class Cell{
   private int x;
   private int y;
   private int direction;
   private boolean food;
   private boolean isSnake;
   /*
   Direction Codes:
   0 = "null"
   1 = "up"
   2 = "right"
   3 = "down"
   4 = "left"
   */
   public Cell(int posX, int posY){
      x = posX;
      y = posY;
      direction = 0;
      food = false;
      isSnake = false;
      
   }
   public int getX(){return this.x;}
   public int getY(){return this.y;}
   public int getDirection(){return this.direction;}
   public boolean isFood(){return this.food;}
   public boolean isSnake(){return this.isSnake;}
   
   public void changeDirection(int dir){this.direction = dir;}
   public void editFood(boolean food){this.food = food;}
   public void editSnake(boolean state){this.isSnake = state;}
}
