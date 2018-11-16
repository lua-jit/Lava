module screen;
import std.stdio;
import std.algorithm;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import lava;

SDL_Window* window;
SDL_Renderer* renderer;
SDL_Texture* prescreenTexture;
int windowXsize;
int windowYsize;
int renderScale;
double width;
double height;

/*
 * - Load SDL2
 * - set window params
 * - create window
 * - create renderer
 * - create render buffer
 */
void init(string windowTitle, int inpWindowXsize, 
  int inpWindowYsize, int inpRenderScale, bool resizable = true) {

  loadDerelict();

  windowXsize = inpWindowXsize;
  windowYsize = inpWindowYsize;
  renderScale = inpRenderScale;

  width = cast(int)(inpWindowXsize/inpRenderScale);
  height = cast(int)(inpWindowYsize/inpRenderScale);
  
  uint windowFlags = SDL_WINDOW_SHOWN;
  if (resizable) windowFlags |= SDL_WINDOW_RESIZABLE;
  window = SDL_CreateWindow(cast(char*)windowTitle, SDL_WINDOWPOS_UNDEFINED, 
    SDL_WINDOWPOS_UNDEFINED, windowXsize, windowYsize, windowFlags);
  renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
  prescreenTexture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, 
    SDL_TEXTUREACCESS_TARGET, inpWindowXsize/inpRenderScale, inpWindowYsize/inpRenderScale);
  SDL_SetRenderTarget(renderer, prescreenTexture);
  SDL_AddEventWatch(&eventWindow, window);
}

private void loadDerelict(){
  DerelictSDL2.load();
  DerelictSDL2Image.load();
  DerelictSDL2ttf.load();
  TTF_Init();
}

void clear(){
  SDL_SetRenderDrawColor(screen.renderer, 255, 255, 255, 255);
  SDL_RenderClear(screen.renderer);
}

void copyPrescreenToBuffer(){
  int w, h;
  SDL_GetWindowSize(window, &w, &h);

  SDL_Rect prescreenRect = { 0, 0, windowXsize/renderScale, windowYsize/renderScale };

  double sizex = windowXsize/renderScale;
  double sixey = windowYsize/renderScale;

  double wScale = min(w/sizex, h/sixey);
  double ratio = sizex/sixey; 
  int xoffset = cast(int)max(((w - h*ratio)/2), 0);
  int yoffset = cast(int)max(((h - w/ratio)/2), 0);

  SDL_Rect windowRect = { xoffset, yoffset, 
    cast(int)((windowXsize/renderScale)*wScale), cast(int)((windowYsize/renderScale)*wScale) };

  // Display on screen
  SDL_SetRenderTarget(renderer, null);
  SDL_RenderCopy(renderer, prescreenTexture, &prescreenRect, &windowRect);
}

void present(){
  SDL_RenderPresent(screen.renderer);
  SDL_SetRenderTarget(renderer, prescreenTexture);
}

void setWindowTitle(string title){
  SDL_SetWindowTitle(window, cast(char*)title);
}

void destroy(){
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
}

// Called when window is modified
extern (C) int eventWindow(void* data, SDL_Event* event) nothrow {
  return 0;
}