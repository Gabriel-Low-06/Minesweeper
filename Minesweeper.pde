import de.bezier.guido.*; 
float Level = .5; //stores difficulty level
int NUM_ROWS = (int)(Level*15); //variables to store size of grid (complexity of game)
int NUM_COLS = (int)(Level*15);
String introMessage = "Welcome to Minesweeper. In a second, you will be shown a \nmap of an aquatic minefield, and your task is to uncover \nall"
  +" the areas around the mines, so that they can be removed.\nTo uncover squares, left-click on them. If you think \nsomething is a mine, flag it by right-clicking." 
  +" Some squares \ngive you numbers; these tell you how many adjacent mines \nthere are, and are necessary to find the mines.\nTime is of the essence, so be sure to hurry! "
  +"\nAnd try to avoid being blown up.";
final int theme = color  (70, 130, 180); //
public boolean hasSetMines; //stores whether or not you've set the mines yet
public boolean levelSelecting = false; //stores whether or not you're dragging the difficulty slider
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined
public boolean isLost; //stores... if the game *is lost*
int HighScore; //stores high score
int ScoreNow; //keeps track of the time of the current game
int timekeep; // variable to track when a given round started (used with scorenow)
void setup () {
  Interactive.make(this); //this is necessary to use the guido library
  HighScore=200000000; //sets an original high score ludicrously high, so anything beats it
  size(801, 601);
  textAlign(CENTER, CENTER); 
  initGame(); //sets up all variables
}

void initGame() {
  timekeep=millis();
  // make the manager
  if (millis()>800) {
    for (int i=0; i<NUM_ROWS; i++) {
      for (int q=0; q<NUM_COLS; q++) {
        buttons[i][q].refresh(); //clears the data from the previous game
      }
    }
  }
  NUM_ROWS = (int)(Level*15);
  NUM_COLS = (int)(Level*15);
  mines = new ArrayList<MSButton>();
  buttons= new MSButton[NUM_ROWS][NUM_COLS];
  for (int i=0; i<NUM_ROWS; i++) {
    for (int q=0; q<NUM_COLS; q++) { //sets up all the buttons, initialized based on the grid size
      buttons[i][q]=new MSButton(i, q);
    }
  }
  Interactive.setActive(buttons, true);
  isLost=false;
  hasSetMines=false;
}

void keyPressed() {
  if (isLost||isWon())initGame(); //reset the game when you click a key
}

public void setMines(int x, int y) { //sets a bunch of mines at random locations
  int stillRun=0;
  while (stillRun<(NUM_ROWS*1.3*Level)) {
    //sets number of mines based on how big the board is and how hard the game is
    int rCol = (int)random(0, NUM_COLS+1);
    int rRow = (int)random(0, NUM_ROWS+1);
    //randomly picks a location
    if (isValid(rRow, rCol) && (rRow<x-1 || rRow>x+1 || rCol<y-1 || rCol>y+1) && !mines.contains(buttons[rCol][rRow])) {
      //adds a mine to that location if there isn't any mine already, AND IF that location is not right next to the piece you just clicked
      //(the reason for the second part is so that you never lose on your first turn)
      mines.add(buttons[rRow][rCol]); //actually adds the mine
      stillRun++;
    }
  }
}

void mouseReleased() {
  if (levelSelecting) {
    levelSelecting=false; //once you've finished dragging the slider to select your level, and you release it, it resets the game at that level
    initGame();
  }
}
public void draw () {
  background(theme); //make the background the given color theme
  if (!isWon()&&!isLost) ScoreNow=(millis()-timekeep)/1000;

  fill(150, 100, 50); 
  for (int i=0; i<4; i++) { //this whole block of code draws the text with the timer and high score and whatnot, but it does so with fancy 3D font
    textSize(30);
    text("Timer: "+(int)(ScoreNow), 680, 30);
    text("Pers. Record:", 700, 90);
    text(HighScore+"s", 700, 130);
    textSize(24);
    text("Difficulty Slider:", 700, 180);
    translate(1, 1);
    if (i>1) {
      fill(196, 180, 84);
    }
  }
  translate(-4, -4);

  strokeWeight(3); //the block of code below draws the slider that controls level changing
  stroke(196, 180, 84);
  fill(255);
  rect(610, 210, 180, 14);
  fill(0);
  rect(560+(Level*140), 205, 25, 25);
  //the block below actually *controls* the lever, by adjusting the coordinates of the slider and the lever when you mouseclick and drag
  if (mousePressed && mouseX>(555+(Level*140)) && mouseX<(590+(Level*140))||levelSelecting) {
    Level=constrain((mouseX-572.5)/(float)140, .35, 1.5);
    levelSelecting = true;
  }
  strokeWeight(1); //resets line color and thickness to defaults so it doesn't screw with the rest of the program
  stroke(0);
}
public boolean isWon() {
  //used to determine if you've won or not
  if (isLost)return false;
  for (int x=0; x<NUM_ROWS; x++) {
    for (int y=0; y<NUM_ROWS; y++) {
      if ((buttons[x][y].unClicked()||buttons[x][y].isFlagged())&&!mines.contains(buttons[x][y]))return false;
      //essentially, this runs through every button, and if there's a button that is not a mine, and you haven't clicked it yet, that you haven't won yet
    }
  }
  return true; //if that's not true: hey, you won!
}
public void displayLosingMessage() {
  //this is a function to display the message shown...  when you lose
  fill(255, 255, 255);
  textSize(100);
  text("You Lose", 300, 200);
  textSize(30);
  text("Press Any Key to Play Again!", 300, 280);
  textSize(10);
}
public void displayWinningMessage() {
  //same as above, but for winning
  fill(255, 255, 255);
  textSize(100);
  text("You Win!", 300, 200);
  textSize(30);
  text("Press Any Key to Play Again!", 300, 280);
  textSize(10);
}
public boolean isValid(int r, int c) {
  //a handy function used to avoid IndexOutOfBoundsErrors -- checks if a given square is actually withing the boundaries of the game
  if (r>=0 && c>=0 && r<NUM_ROWS && c<NUM_COLS) {
    return true;
  }
  return false;
}
public int countMines(int row, int col) {
  //this uses is valid (to make sure the adjacent square exists) and mines.contains to return the number of mines adjacent to a given square
  int numMines = 0;
  if (isValid(row+1, col) && mines.contains(buttons[row+1][col])) numMines++;
  if (isValid(row-1, col) && mines.contains(buttons[row-1][col])) numMines++;
  if (isValid(row, col+1) && mines.contains(buttons[row][col+1])) numMines++;
  if (isValid(row, col-1) && mines.contains(buttons[row][col-1])) numMines++;
  //if you're thinking "this is a freaking massive block of code", you're right. I just brute forced all eight adjacent squares.
  //there was probably a more efficient way to do this, but I was too lazy to figure it out
  if (isValid(row+1, col+1) && mines.contains(buttons[row+1][col+1])) numMines++;
  if (isValid(row+1, col-1) && mines.contains(buttons[row+1][col-1])) numMines++;
  if (isValid(row-1, col+1) && mines.contains(buttons[row-1][col+1])) numMines++;
  if (isValid(row-1, col-1) && mines.contains(buttons[row-1][col-1])) numMines++;
  return numMines;
}
public class MSButton {
  //welcome to the actual object class for the button. This is where most of the important code is that runs the actual game.
  private int myRow, myCol; 
  private float x, y, width, height; //^ all the above and left are variables that basically tell the computer where to draw the button, and how big to make it
  private boolean clicked, flagged; //variables to store if a button... has been clicked or flagged
  private String myLabel; //tells the computer what number (if any) to draw on the button

  public MSButton ( int row, int col ) {
    //initializes an unclicked, unflagged button at the given row-col coordinates
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
    Interactive.setActive(this, false);
    //this removes a given button from the manager (when I didn't do this, everytime you replayed the game it layered more and more buttons on top of each other...
    // ... and eventually probably would've crashed my computer
  }

  public void mousePressed () {
    //welcome to the long and convoluted saga of what to do when the user actuallly clicks a button
    if (clicked &&!flagged)mouseButton=LEFT;
    if (!hasSetMines) { //if this is the first click in a game, then set the mines 
      setMines(myRow, myCol);
      hasSetMines=true;
    }
    clicked = true; //sets clicked to true, because you clicked it
    if (mouseButton==RIGHT) { //if you right click, it flags the square
      flagged=!flagged;
      if (!flagged) { //if it was already flagged, it unflags it and unclicks it too for good measure
        clicked=false;
      }
    } else if (mines.contains(this) &&!flagged) { //if you just clicked on a mine that you haven't flagged...
      isLost=true; //... well, you've lost
    } else if (countMines(myRow, myCol)>0) { //if you clicked on a non-mine that's adjacent to some mines
      flagged=false; //unflags it (if it was even flagged in the first place)
      setLabel(countMines(myRow, myCol)); //sets the label to the number of mines around it
    } else {
      //otherwise, if you've clicked on a non-mine that's not even *adjacent* to any mines, then recurse outwards..
      //...calling mouseclicked on all its neighbors, so that it reveals a bunch of obviously non-mines, instead of making you tediously do it all yourself
      if (isValid(myRow+1, myCol) && buttons[myRow+1][myCol].unClicked())  buttons[myRow+1][myCol].mousePressed();
      if (isValid(myRow-1, myCol) && buttons[myRow-1][myCol].unClicked()) buttons[myRow-1][myCol].mousePressed();
      if (isValid(myRow, myCol+1) && buttons[myRow][myCol+1].unClicked()) buttons[myRow][myCol+1].mousePressed();
      //yes, this is another massive block of code. also, if that explanation was confusing, you'll just have to play the game and see how it looks
      if (isValid(myRow, myCol-1) && buttons[myRow][myCol-1].unClicked()) buttons[myRow][myCol-1].mousePressed();
      if (isValid(myRow+1, myCol+1) && buttons[myRow+1][myCol+1].unClicked())   buttons[myRow+1][myCol+1].mousePressed();
      if (isValid(myRow+1, myCol-1) && buttons[myRow+1][myCol-1].unClicked())  buttons[myRow+1][myCol-1].mousePressed();
      if (isValid(myRow-1, myCol+1) && buttons[myRow-1][myCol+1].unClicked()) buttons[myRow-1][myCol+1].mousePressed();
      if (isValid(myRow-1, myCol-1) && buttons[myRow-1][myCol-1].unClicked()) buttons[myRow-1][myCol-1].mousePressed();
    }
    if (isWon()) {
      if (ScoreNow<HighScore)HighScore=ScoreNow; //if you won on that click, and you beat your record, set your record to this new time
    }
  }

  public boolean unClicked() {
    return !clicked; //symbol member getter to return the negation of clicked
  }

  public void draw () {
    //the second most important member function; this actualy draws all the mines
    if (isLost) if (mines.contains(this))clicked=true;  //reveals all the mines if you've lost
    if ( clicked && !flagged && mines.contains(this) ) { //if it's clicked, and it's a mine, draw it bright bold red
      fill(255, 0, 0);
    } else if (clicked && !flagged) { //otherwise, if you've clicked it, draw it in boring brown color
      fill( 150, 100, 50 );
      if (myLabel=="")fill(196, 180, 84); //unless it's in the middle, then it's bright gold! (because why not?)
    } else {
      fill(theme); //if you haven't clicked it all, draw at as the theme color
    }
    rect(x, y, width, height); //now that the color has been decided, this actually draws the button in that color

    if (flagged) { //if it's flagged, this code draws a nice little flag on top of it
      fill(0);
      rect(x+(width/6), y+(width/4), width*.1, height*.7);
      fill(255);
      if (isLost && mines.contains(this))fill(255, 50, 50); //but if you've lost, and the flag *was* a mine, now the flag is red to show you
      rect(x+(width/6), y+(width/6), width*.7, height/3);
    }

    fill(0);
    textSize(20); //this little chunk of code draws the label on top of the square
    text(myLabel, x+width/2, y+height/2);

    if (isLost && myRow==NUM_ROWS-1 && myCol==NUM_COLS-1)displayLosingMessage(); 
    //if you've lost or won (and this is the last button being drawn) then show the corresponding end screen
    if (isWon() && myRow==NUM_ROWS-1 && myCol==NUM_COLS-1)displayWinningMessage();
    
    if (myRow==NUM_ROWS-1 && myCol==NUM_COLS-1 && millis()<28400) {
      textAlign(LEFT);
      background(theme);
      fill(255);
      textSize(25);
      pushMatrix();
      translate(400, 300);
      rotate(constrain((millis()-27000)*.01, 0, 8000000));
      scale(constrain(pow(1.6, (millis()-27000)*.01), 1, 8000000));
      String toPrint = introMessage.substring(0, (int)(constrain(millis()*.020, 0, introMessage.length())));
      if (((int)millis()/500)%2==0) {
        text(toPrint+"|", -350, -250);
      } else {
        text(toPrint, -350, -250);
      }
      popMatrix();
      textAlign(CENTER);
    }
    
  }
  public void setLabel(String newLabel) { //that's basically it, everything else is just simple getters and setters.
    myLabel = newLabel;
  }
  public void setLabel(int newLabel) {
    myLabel = ""+ newLabel;
  }
  public boolean isFlagged() {
    return flagged;
  }
}
