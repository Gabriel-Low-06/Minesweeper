import de.bezier.guido.*; //completed step 12
int NUM_ROWS = 15;
int NUM_COLS = 15;
public boolean hasSetMines;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined
public boolean isLost; 
int HighScore;
int timekeep;
void setup () {
  HighScore=Integer.MAX_VALUE;
  size(801, 601);
  textAlign(CENTER, CENTER);
  Interactive.make(this);
  buttons= new MSButton[NUM_ROWS][NUM_COLS];
  for (int i=0; i<NUM_ROWS; i++) {
    for (int q=0; q<NUM_COLS; q++) {
      buttons[i][q]=new MSButton(i, q);
    }
  }
  initGame();
}

void initGame() {
  timekeep=millis();
  // make the manager
  Interactive.make( this );
  mines = new ArrayList<MSButton>();
  for (int i=0; i<NUM_ROWS; i++) {
    for (int q=0; q<NUM_COLS; q++) {
      buttons[i][q].refresh();
    }
  }
  //end of mysterious setup code
  isLost=false;
  hasSetMines=false;
}

void keyPressed() {
  if (isLost||isWon())initGame();
}

public void setMines(int x, int y) {
  int stillRun=0;
  while (stillRun<(NUM_ROWS*1.3)) {
    int rCol = (int)random(0, NUM_COLS+1);
    int rRow = (int)random(0, NUM_ROWS+1);
    if (isValid(rRow, rCol) && (rRow<x-1 || rRow>x+1 || rCol<y-1 || rCol>y+1) && !mines.contains(buttons[rCol][rRow])) {
      mines.add(buttons[rRow][rCol]);
      stillRun++;
    }
  }
}

public void draw () {
  background(100, 200, 50);
  textSize(38);
  fill(0);
  if (!isWon()&&!isLost) {
    text("Time: "+(millis()-timekeep)/1000, 700, 30);
  } else { 
    text("Time: "+(timekeep/1000), 700, 30);
  }
  fill(100, 100, 200);
  textSize(30);
  text("High Score:", 700, 90);
  text(HighScore, 700, 130);

  textSize(14);
}
public boolean isWon()
{
  if (isLost)return false;
  for (int x=0; x<NUM_ROWS; x++) {
    for (int y=0; y<NUM_ROWS; y++) {
      if (buttons[x][y].unClicked()&&!mines.contains(buttons[x][y]))return false;
    }
  }
  return true;
}
public void displayLosingMessage() {
  fill(255, 255, 255);
  textSize(100);
  text("You Lose", 300, 100);
  textSize(30);
  text("Press Any Key to Play Again!", 300, 180);
  textSize(10);
}
public void displayWinningMessage() {
  fill(155, 155, 255);
  textSize(100);
  text("You Win!", 300, 200);
  textSize(30);
  text("Press Any Key to Play Again!", 300, 280);
  textSize(10);
}
public boolean isValid(int r, int c) {
  if (r>=0 && c>=0 && r<NUM_ROWS && c<NUM_COLS) {
    return true;
  }
  return false;
}
public int countMines(int row, int col) {
  int numMines = 0;
  if (isValid(row+1, col) && mines.contains(buttons[row+1][col])) numMines++;
  if (isValid(row-1, col) && mines.contains(buttons[row-1][col])) numMines++;
  if (isValid(row, col+1) && mines.contains(buttons[row][col+1])) numMines++;
  if (isValid(row, col-1) && mines.contains(buttons[row][col-1])) numMines++;
  if (isValid(row+1, col+1) && mines.contains(buttons[row+1][col+1])) numMines++;
  if (isValid(row+1, col-1) && mines.contains(buttons[row+1][col-1])) numMines++;
  if (isValid(row-1, col+1) && mines.contains(buttons[row-1][col+1])) numMines++;
  if (isValid(row-1, col-1) && mines.contains(buttons[row-1][col-1])) numMines++;
  return numMines;
}
public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton ( int row, int col ) {
    width = 600/NUM_COLS;
    height = 600/NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol*width;
    y = myRow*height;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add( this ); // register it with the manager
  }

  public void refresh() {
    flagged=clicked=false;
    myLabel="";
  }

  // called by manager
  public void mousePressed () {
    if (clicked &&!flagged)mouseButton=LEFT;
    if (!hasSetMines) {
      setMines(myRow, myCol);
      hasSetMines=true;
    }
    clicked = true;
    if (mouseButton==RIGHT) {
      flagged=!flagged;
      if (!flagged) {
        clicked=false;
      }
    } else if (mines.contains(this) &&!flagged) {
      isLost=true;
      timekeep=millis()-timekeep;
    } else if (countMines(myRow, myCol)>0) {
      setLabel(countMines(myRow, myCol));
    } else {
      mouseButton=LEFT;
      if (isValid(myRow+1, myCol) && buttons[myRow+1][myCol].unClicked())  buttons[myRow+1][myCol].mousePressed();
      if (isValid(myRow-1, myCol) && buttons[myRow-1][myCol].unClicked()) buttons[myRow-1][myCol].mousePressed();
      if (isValid(myRow, myCol+1) && buttons[myRow][myCol+1].unClicked()) buttons[myRow][myCol+1].mousePressed();
      if (isValid(myRow, myCol-1) && buttons[myRow][myCol-1].unClicked()) buttons[myRow][myCol-1].mousePressed();
      if (isValid(myRow+1, myCol+1) && buttons[myRow+1][myCol+1].unClicked())   buttons[myRow+1][myCol+1].mousePressed();
      if (isValid(myRow+1, myCol-1) && buttons[myRow+1][myCol-1].unClicked())  buttons[myRow+1][myCol-1].mousePressed();
      if (isValid(myRow-1, myCol+1) && buttons[myRow-1][myCol+1].unClicked()) buttons[myRow-1][myCol+1].mousePressed();
      if (isValid(myRow-1, myCol-1) && buttons[myRow-1][myCol-1].unClicked()) buttons[myRow-1][myCol-1].mousePressed();
    }
    if (isWon()) {
      timekeep=millis()-timekeep;
      if(timekeep/1000<HighScore)HighScore=timekeep/1000;
    }
  }

  public boolean unClicked() {
    return !clicked;
  }

  public void draw () 
  {    
    if (isLost) if (mines.contains(this))clicked=true;  
    if ( clicked && !flagged && mines.contains(this) ) { 
      fill(255, 0, 0);
    } else if (clicked && !flagged) {
      fill( 150, 100, 50 );
    } else {
      fill( 100, 200, 50 );
    }
    rect(x, y, width, height);

    if (flagged) {
      fill(0);
      rect(x+(width/6), y+(width/4), width*.1, height*.7);
      fill(255);
      rect(x+(width/6), y+(width/6), width*.7, height/3);
    }
    fill(0);
    text(myLabel, x+width/2, y+height/2);
    if (isLost && myRow==NUM_ROWS-1 && myCol==NUM_COLS-1)displayLosingMessage();
    if (isWon() && myRow==NUM_ROWS-1 && myCol==NUM_COLS-1)displayWinningMessage();
  }
  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }
  public void setLabel(int newLabel) {
    myLabel = ""+ newLabel;
  }
  public boolean isFlagged() {
    return flagged;
  }
}
