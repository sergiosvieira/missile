//---------------------------------------------------------
// GameVision (tm) Game Application Framework 2.x
// Copyright (c) 2002 JDS Games
// All Rights Reserved.
//
// TGVFrameRate Class
// used to calculate the elapsed time from frame to frame
// which can be applied to your game objects to keep them
// moving at a constant rate. It will also calculate the
// current speed of your frame.
//---------------------------------------------------------

unit UFrameRate;

interface

Uses
  SysUtils, Classes, Registry, Windows, Dialogs;

type
TGVFrameRate = class(TObject)
  private
    FCurTime            : Comp;    // current time tick
    FLastTime           : Comp;    // last time tick
    FDesiredFPS         : Single;   // minimum elapsed time
    FMinElapsedTime     : Single;   // max elapsed time
    FMaxElapsedTime     : Single;   // elapsed time scale
    FElapsedTimeScale   : Single;   // framerate elapsed time scale
    FFPSTimeScale       : Single;   // framerate time scale
    FFPSElapsedTime     : Single;   // framerate elapsed time
    FElapsedTime        : Single;   // elapsed time
    FFrameRate          : Cardinal; // current framerate
    FFrameCount         : Cardinal; // frame count
  public
    property Rate       : Cardinal read FFrameRate;
    property ElapsedTime: Single   read FElapsedTime;
    constructor Create;
    destructor Destroy; override;
    procedure Init(DesiredFPS: Double; MinElapsedTime, MaxElapsedTime: Single);
    procedure Update;
  end;


implementation




//---------------------------------------------------------
// constructor TGVFrameRate.Create;
// Default constructor for TSBFrameRate class. It will init
// to a default desired framerate of 35 fps.
//---------------------------------------------------------

constructor TGVFrameRate.Create;
begin
  inherited Create;
  Init(35.0, 0, 3);
end;

//---------------------------------------------------------
// destructor TGVFrameRate.Destroy;
// Default destructor for TGVFrameRate
//---------------------------------------------------------

destructor TGVFrameRate.Destroy;

begin

  inherited Destroy;

end;

//---------------------------------------------------------
// procedure TGVFrameRate.Init;
// Initialize TSBFrameRate to desired fps. You can also
// specify the minimum and maximum elapsed time allowed to
// pass. This will eliminate the big jumps in movement when
// there is a long delay in processing, such as hard drive
// activity or inactivity during a context switch. Typical
// values that work are 0 and 3.
//---------------------------------------------------------

procedure TGVFrameRate.Init;
begin
  QueryPerformanceFrequency(TLargeInteger(FLastTime));
//FLastTime_:= FLastTime;
  FDesiredFPS := DesiredFPS;
  FMinElapsedTime := MinElapsedTime;
  FMaxElapsedTime := MaxElapsedTime;
  FElapsedTimeScale := FDesiredFPS / FLastTime;
  FFPSTimeScale := 1.0 / FLastTime;
end;

//---------------------------------------------------------
// procedure TGVFrameRate.Update
// calculate the current elapsed time for the frame and
// the current fps.
//---------------------------------------------------------

procedure TGVFrameRate.Update;

begin
  // calc elapsed time
  QueryPerformanceCounter(TLargeInteger(FCurTime));
  FElapsedTime := (FCurTime - FLastTime) * FElapsedTimeScale;
  if FElapsedTime < FMinElapsedTime then
    FElapsedTime := FMinElapsedTime
  else if FElapsedTime > FMaxElapsedTime
    then FElapsedTime := FMaxElapsedTime;
  // calc frame rate
  Inc(FFrameCount);
  FFPSElapsedTime := FFPSElapsedTime + ((FCurTime - FLastTime) * FFPSTimeScale);
  if FFPSElapsedTime >= 1 then
  begin
    FFPSElapsedTime := 0;
    FFrameRate := FFrameCount;
    FFrameCount := 0;
  end;
  FLastTime := FCurTime;
end;

end.
