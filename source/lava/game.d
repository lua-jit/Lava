module game;
import std.stdio;
import std.conv;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import lava;

private GameObject[] gameObjects;
private bool shouldQuit = false;

public int ticksBuffer = 0;

bool lavaShouldQuit(){
  return shouldQuit;
}
void lavaQuitLoop(){
  shouldQuit = true;
}
void lavaLoopStep(void delegate() _userDefinedLoopFunc) {
  int ticksCurrent = SDL_GetTicks();
  if(game.ticksBuffer + 1000/60 < ticksCurrent){
    int presetp = SDL_GetTicks();
    game.ticksBuffer = ticksCurrent;
    SDL_Event e;
    bool quit = false;
    while(SDL_PollEvent(&e)){
      quit = handleEvent(e);
    }
    _userDefinedLoopFunc();
    keyboard.clearPressedKeys();
    if(quit){lavaQuitLoop();}
  }
  SDL_Delay(1);
}

/* Base Object template */
class GameObject {
  double x;
  double y;
  void step(){};
}

void stepAll() {
  /* update and draw stuff */
  foreach(object; gameObjects) {
    object.step();
  }
}

void addObject(GameObject obj){
  game.gameObjects ~= obj;
}

bool handleEvent(SDL_Event e){
  switch(e.type){
    case SDL_QUIT: return true;
    case SDL_KEYDOWN: if(e.key.repeat == 0) keyboard.passPressedKey(e.key.keysym);
    break;
    case SDL_KEYUP: if(e.key.repeat == 0) keyboard.passLiftedKey(e.key.keysym);
    break;
    case SDL_WINDOWEVENT:
    if(e.window.event == SDL_WINDOWEVENT_RESIZED){
      _log("Window %d size changed to %dx%d",
              e.window.windowID, e.window.data1,
              e.window.data2);
    }
    break;
    default: break;
  }
  return false;
}

public void quit(){
  printf("Quitting");
  TTF_Quit();
  screen.destroy();
  SDL_Quit();
}