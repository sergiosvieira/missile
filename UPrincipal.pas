unit UPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,UFrameRate;

type
  TFmMain = class(TForm)
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure color(cor:tcolor);
  end;
  TCena = (Inicio,Jogando,GameOver);
  TMissel = object
    VelEscalar: Double;
    xPos,yPos: Double;
    Lar,Alt: Integer;
    xDes,yDes: Double;
    xVel,yVel: Double;
    n: integer;
    Vivo: Boolean;
  protected
    procedure Mover;
    function NoDestino: boolean;
    procedure Explodir;
  end;

  TMissel_ = object
    VelEscalar: Double;
    xPos,yPos: Double;
    Lar,Alt: Integer;
    n: integer;
    Vivo: Boolean;
  protected
    procedure Mover;
    procedure Explodir;
  end;


  TEnemy = object
    xPos,yPos: Double;
    Lar,Alt: Integer;
    Vel: Double;
    Angulo: integer;
  protected
    procedure Mover(xAngulo: integer);
  end;
  TPredios = object
    xPos,yPos: Integer;
    Lar,Alt: Integer;
    Vivo: Boolean;
  protected
    procedure Explodir;
  end;
  TDir = (Esquerda,Direita);
  TBoss = object
    xPos,yPos: Double;
    Life: Double;
    Lar,Alt: Integer;
    Sentido: TDir;
    Vel: Double;
    Ang: Double;
    Vivo: Boolean;
  protected
    procedure Mover;
    procedure Explodir;
    procedure Atirar;
  end;

const
  NM = 10;
  NI = 20;
  NP = 10;
  GBOSS = '<\-|:|:|-/>';

var
  FmMain: TFmMain;
  Buffer: TBitmap;
  xOrigem,yOrigem: Double;
  Misseis : array[0..NM] of TMissel;
  Misseis_: array[0..NM] of TMissel_;
  Inimigos: array[0..NI] of TEnemy;
  Predios : array[0..NP] of TPredios;
  Cena: TCena;
  Pontos,Baixas,PontosChefe: Integer;
  FrameRate: TGVFrameRate;
  Boss: TBoss;
  val: integer = 0;
  Turbo: Boolean = false;

implementation

{$R *.DFM}

{ DETECÇÃO DE COLISÃO }
function Colisao(x1,y1,w1,h1,x2,y2,w2,h2:Integer):Boolean;
begin
  if (x1 <= x2 + w2) and
     (x1 + w1 >= x2) and
     (y1 <= y2 + h2) and
     (y1 + h1 >= y2) then
     Result := True
  else
     Result := False;
end;

{ TBoss }
procedure TBoss.Mover;
begin
  case Sentido of
       Direita :  xPos:= xPos + Vel * FrameRate.ElapsedTime;
       Esquerda:  xPos:= xPos - Vel * FrameRate.ElapsedTime;
  end;
  //yPos:= yPos + 1) + Vel * FrameRate.ElapsedTime;
  if xPos+Lar>Buffer.Width - 5 then
     Sentido:= Esquerda;
  if xPos<5 then
     Sentido:= Direita;
  Buffer.Canvas.TextOut(Trunc(xPos),Trunc(yPos),GBOSS);
end;

procedure TBoss.Explodir;
var
  i: integer;
begin
  if not (val mod 1000=0) then
     for i:= 0  to 5 do
         begin
           Buffer.Canvas.TextOut(Trunc(xPos)+i*4,Trunc(yPos)-i*4,'X');
           Buffer.Canvas.TextOut(Trunc(xPos)-i*4,Trunc(yPos)+i*4,'X');
         end;
end;

procedure TBoss.Atirar;
var
  i: integer;
begin
  for i:= 0 to NM do
      with Misseis_[i] do
      if val mod 80 = 0 then
      if not Vivo then
         begin
           xPos:= Boss.xPos + Boss.Lar div 2;
           yPos:= Boss.yPos;
           Vivo:= True;
           Break;
         end;
end;

{ TEnemy }

procedure TEnemy.Mover;
var
  i: integer;
begin
  xPos:= xPos + Sin(xAngulo) * Vel * FrameRate.ElapsedTime;
  yPos:= yPos + Cos(xAngulo) * Vel * FrameRate.ElapsedTime;
  for i:= 0 to NM do
      if Misseis[i].Vivo then
      if Colisao(Trunc(Misseis[i].xPos),Trunc(Misseis[i].yPos),Misseis[i].Lar,
         Misseis[i].Alt,Trunc(xPos),Trunc(yPos),10,10) then
         begin
           yPos:= Buffer.Height + 5;
           Inc(Pontos,100);
         end;
  for i:= 0 to NP do
      if Predios[i].Vivo then
      if Colisao(Trunc(xPos),Trunc(yPos),Lar,Alt,
                 Trunc(Predios[i].xPos),Trunc(Predios[i].yPos),Predios[i].Lar,Predios[i].Alt) then
         begin
           Predios[i].Explodir;
           Predios[i].Vivo:= False;
           Inc(Baixas);
         end;
  if Colisao(Trunc(xOrigem),Trunc(yOrigem),Buffer.Canvas.TextWidth('|/\|'),Buffer.Canvas.TextHeight('|/\|'),
             Trunc(xPos),Trunc(yPos),10,10) then
     Cena:= GameOver;
  Buffer.Canvas.TextOut(Trunc(xPos),Trunc(yPos),'v');
  if yPos>Buffer.Height then
     begin
        xPos:= Random(Buffer.Width);
        yPos:= Random(Buffer.Height)*-5.2;
        if Vel>1.2 then
           Vel:= 1.2
        else
           Vel:= Vel + 0.1;
        Angulo:= Random(2);
     end;
end;

{ TMissel_ }

procedure TMissel_.Explodir;
var
  i: integer;
begin
  FmMain.Color(clYellow);
  for i:= 1 to 5 do
      Buffer.Canvas.TextOut(Trunc(xPos)+i*2,Trunc(yPos)-i*2,'X');
end;

procedure TMissel_.Mover;
var
  i: integer;
begin
  yPos:= yPos + VelEscalar * FrameRate.ElapsedTime;
  if yPos>Buffer.Height then
     Vivo:= False;
  for i:= 0 to NM do
  if Misseis[i].Vivo then
  if Colisao(Trunc(xPos),Trunc(yPos),Lar,Alt,
             Trunc(Misseis[i].xPos),Trunc(Misseis[i].yPos),
             Misseis[i].Lar,Misseis[i].Alt) then
     begin
       Explodir;
       Vivo:= False;
     end;
  for i:= 0 to NP do
      if Predios[i].Vivo then
      if Colisao(Trunc(xPos),Trunc(yPos),Lar,Alt,
                 Trunc(Predios[i].xPos),Trunc(Predios[i].yPos),Predios[i].Lar,Predios[i].Alt) then
         begin
           Predios[i].Explodir;
           Predios[i].Vivo:= False;
           Inc(Baixas);
         end;
  if Colisao(Trunc(xOrigem),Trunc(yOrigem),Buffer.Canvas.TextWidth('|/\|'),Buffer.Canvas.TextHeight('|/\|'),
             Trunc(xPos),Trunc(yPos),10,10) then
     Cena:= GameOver;
  Buffer.Canvas.TextOut(Trunc(xPos)+6,Trunc(yPos)-3,'Ý');
end;


{ TMissel }

function TMissel.NoDestino;
begin
  if (Abs(xPos - xDes) < 5.1) and
     (Abs(yPos - yDes) < 5.1) then
     Result:= True
  else
     Result:= False;
  if (Abs(xPos - xDes) > 2*Buffer.Width) or
     (Abs(yPos - yDes) > 2*Buffer.Height) then
     Result:= True;
end;

procedure TMissel.Explodir;
var
  i: integer;
begin
  FmMain.Color(clYellow);
  for i:= 1 to 5 do
      Buffer.Canvas.TextOut(Trunc(xPos)+i*2,Trunc(yPos)-i*2,'X');
end;

procedure TMissel.Mover;
begin
  xPos:= xVel*FrameRate.ElapsedTime + xPos;
  yPos:= yVel*FrameRate.ElapsedTime + yPos;
  if (noDestino) then
     begin
       Explodir;
       Vivo:= false;
       xPos:= xOrigem;
       yPos:= yOrigem;
     end
  else
  if (xPos<0) or (xPos>Buffer.Width) or
     (yPos<0) or (yPos>Buffer.Height) then
     Vivo:= False;
  if Boss.Vivo then
     if Colisao(Trunc(xPos),Trunc(yPos),Lar,Alt,
        Trunc(Boss.xPos),Trunc(Boss.yPos),Boss.Lar,Boss.Alt) then
        begin
          Boss.Life:= Boss.Life - 0.02;
          if Trunc(Boss.Life)<=0 then
             begin
               val:= 1;
               Boss.Explodir;
               Boss.Vivo:= False;
               Inc(Pontos,1000);
               PontosChefe:= Pontos;
               Boss.Life:= 10;
             end;
        end;
  Buffer.Canvas.TextOut(Trunc(xPos)+6,Trunc(yPos)-3,'°');
end;

{ TPredio }

procedure TPredios.Explodir;
var
  i: integer;
begin
  FmMain.Color(clYellow);
  for i:= 1 to 5 do
      Buffer.Canvas.TextOut((xPos)+i*2,(yPos)-i*2,'X');
end;

procedure TFmMain.color;
begin
  Buffer.Canvas.Font.Color:= cor;
end;

procedure TFmMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Buffer:= TBitmap.Create;
  Buffer.Width:= ClientWidth;
  Buffer.Height:= 310;

  FrameRate := TGVFrameRate.Create;
  FrameRate.Init(60, 0, 3); // init framerate to 35 fps

  Pontos:= 0;
  Baixas:= 0;
  Cena:= Inicio;
//  Cena:= GameOver;
  xOrigem:= Buffer.Width div 2;
  yOrigem:= Buffer.Height - 15;
  for i:= 0 to NM do
      begin
        with Misseis[i] do
        begin
          VelEscalar:= 2;
          xPos:=xOrigem;yPos:=yOrigem;
          Lar:= 10;
          Alt:= 10;
          xVel:=0;yVel:=0;
          Vivo:= False;
        end;
        with Misseis_[i] do
        begin
          VelEscalar:= 2;
          xPos:= Boss.xPos; yPos:=Boss.yPos;
          Lar:= 10;
          Alt:= 10;
          Vivo:= False;
        end;
      end;
  for i:= 0 to NI do
      with Inimigos[i] do
      begin
        xPos:= Random(Buffer.Width);
        yPos:= Random(Buffer.Height)*-5.2;
        Vel:= 0.5;
        Angulo:= Random(1);
        Lar:= Buffer.Canvas.TextWidth('v');
        Alt:= Buffer.Canvas.TextHeight('v');
      end;
  for i:= 0 to NP do
      begin
        if i<(NP div 2)+1 then
           Predios[i].xPos:= Random((Buffer.Width - 15) div 2)
        else
           Predios[i].xPos:= ((Buffer.Width + 45) div 2) + Random((Buffer.Width - 15) div 2);
        Predios[i].Vivo:= True;
        Predios[i].yPos:= Buffer.Height - 15;
        Predios[i].Lar:= Buffer.Canvas.TextWidth('8');
        Predios[i].Alt:= Buffer.Canvas.TextHeight('8');
      end;
  Boss.Ang:= 1;
  Boss.Vel:= 0.8;
  Boss.xPos:= 1;
  Boss.yPos:= 15;
  Boss.Lar:= Buffer.Canvas.TextWidth(GBOSS);
  Boss.Alt:= Buffer.Canvas.TextHeight(GBOSS);
  Boss.Sentido:= Direita;
  Boss.Vivo:= False;
  Boss.Life:= 10;
  PontosChefe:= 0;
  Buffer.Canvas.Font.Color:= clWhite;
end;

procedure TFmMain.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
  if ssLeft in Shift then
     for i:= 0 to NM do
         with Misseis[i] do
         if not Vivo then
            begin
              xDes:= X-5;yDes:= Y-5;
              Vivo:= True;
              Break;
            end;
end;

procedure TFmMain.FormPaint(Sender: TObject);
var
  Distancia: Double;
  i,x,y: integer;
begin
  x:= 5;y:= 20;
  while not Application.Terminated do
        begin
          Inc(Val);
          Buffer.Canvas.Brush.Color:= clBlack;
          Buffer.Canvas.Brush.Style:= bsSolid;
          Buffer.Canvas.FillRect(Rect(0,0,Buffer.Width,Buffer.Height));
          case Cena of
            Inicio:
              begin
              Buffer.Canvas.Font.Name:= 'FixedSys';
              Buffer.Canvas.Font.Size:= 10;
              Buffer.Canvas.TextOut(x,0+y  ,'       __ \/_');
              Buffer.Canvas.TextOut(x,20+y ,'      (´ \`\');
              Buffer.Canvas.TextOut(x,40+y ,'   _\, \ \\/');
              Buffer.Canvas.TextOut(x,60+y ,'    /`\/\ \\');
              Buffer.Canvas.TextOut(x,80+y ,'         \ \\');
              Buffer.Canvas.TextOut(x,100+y,'          \ \\/\/_');
              Buffer.Canvas.TextOut(x,120+y,'          /\ \\´\');
              Buffer.Canvas.TextOut(x,140+y,'        __\ `\\\');
              Buffer.Canvas.TextOut(x,160+y,'         /|`  `\\');
              Buffer.Canvas.TextOut(x,180+y,'                \\');
              Buffer.Canvas.TextOut(x,200+y,'                 \\');
              Buffer.Canvas.TextOut(x,210+y,'                  \\    ,');
              Buffer.Canvas.TextOut(x,220+y,'                   `---´');
              Color(clYellow);
              Buffer.Canvas.TextOut(180,50,'ASCII MISSILE COMMAND');
              Color($0000FF80);
              Buffer.Canvas.TextOut(120,70,'Developer sergiosvieira@hotmail.com');
              Color(clWhite);
              Buffer.Canvas.TextOut(180,90,'key a - Turbo ON');
              Buffer.Canvas.TextOut(180,110,'key s - Turbo OFF');
              Buffer.Canvas.TextOut(180,150,'Press ENTER to Start');
              Buffer.Canvas.TextOut((Buffer.Width div 2)-
                 (Buffer.Canvas.TextWidth('CopyRight(C) 2003 - All Rights Reserved') div 2),
                 290,'CopyRight(C) 2003 - All Rights Reserved');
              if GetKeyState(VK_RETURN)<0 then
                 begin
                   Buffer.Canvas.Font.Name:= 'Tahoma';
                   Buffer.Canvas.Font.Size:= 12;
                   Cena:= Jogando;
                 end;
              end;
            Jogando:
              begin
                if (not (Boss.Vivo)) and (Pontos=PontosChefe + 2000) then
                   Boss.Vivo:= true;
                Color(clWhite);
                Buffer.Canvas.Brush.Style:= bsClear;
                Buffer.Canvas.Font.Size:= 10;
                Buffer.Canvas.TextOut(5,5,'SCORE: ' + InttoStr(Pontos));
                Buffer.Canvas.TextOut(Trunc(xOrigem),Trunc(yOrigem),'|/\|');
                if Boss.Vivo then
                   begin
                     Boss.Mover;
                     Color(clLime);
                     Boss.Atirar;
                   end;
                for i:= 0 to NM do
                    begin
                      if Boss.Vivo then
                         with Misseis_[i] do
                              if Vivo then
                                 Mover;
                      Color($00FFFF80);
                      with Misseis[i] do
                      if Vivo then
                       begin
                         Distancia:= Sqrt((xOrigem - xDes)*(xOrigem - xDes)
                         + (yOrigem - yDes)*(yOrigem - yDes));
                         xVel:= VelEscalar/Distancia*(xDes - xOrigem);
                         yVel:= VelEscalar/Distancia*(yDes - yOrigem);
                         Mover;
                       end;
                    end;
               Color(clYellow);
               for i:= 0 to NI do
                   with Inimigos[i] do
                   begin
                     Mover(Angulo);
                   end;

               Color(clGray);
               for i:= 0 to NP do
                   if Predios[i].Vivo then
                      Buffer.Canvas.TextOut(Trunc(Predios[i].xPos),Trunc(Predios[i].yPos),'8');
               if Baixas=NP then
                  Cena:= GameOver;
               if Boss.Vivo then
                    Buffer.Canvas.TextOut(5,25,'BOSS: ' + InttoStr(Trunc(Boss.Life)));
               FrameRate.Update;
              end;
            GameOver:
              begin
                Boss.Vivo:= False;
                Boss.Life:= 10;
                Buffer.Canvas.Font.Name:= 'FixedSys';
                Color(clWhite);
                Buffer.Canvas.TextOut((Buffer.Width div 2)-
                 (Buffer.Canvas.TextWidth('GAME OVER') div 2),
                 150,'GAME OVER');
                Buffer.Canvas.TextOut((Buffer.Width div 2)-
                 (Buffer.Canvas.TextWidth('PRESS ENTER TO PLAY AGAIN') div 2),
                 170,'PRESS ENTER TO PLAY AGAIN');
                Buffer.Canvas.TextOut((Buffer.Width div 2)-
                 (Buffer.Canvas.TextWidth('FINAL SCORE: ' + InttoStr(Pontos)) div 2),
                 190,'FINAL SCORE: ' + InttoStr(Pontos));

                if GetKeyState(VK_RETURN)<0 then
                   begin
                     Pontos:= 0;
                     PontosChefe:= 0;
                     Baixas:= 0;
                     for i:= 0 to NI do
                         Inimigos[i].yPos:= Buffer.Height + 5;
                     for i:= 0 to NP do
                         Predios[i].Vivo:= True;
                     for i:= 0 to NM do
                         Misseis_[i].Vivo:= False;
                     Cena:= Inicio;
                   end;
               end;
          end;
          PaintBox1.Canvas.Draw(0,0,Buffer);
          Application.ProcessMessages;
        end;

end;

procedure TFmMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key='a' then
     Turbo:= True;
  if key='s' then
     Turbo:= false;
  if key=#27 then
     close;
end;

procedure TFmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FrameRate.Free;
  Buffer.Free;
end;

procedure TFmMain.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i: integer;
begin
  if Turbo then
     for i:= 0 to NM do
         with Misseis[i] do
         if not Vivo then
            begin
              xDes:= X-5;yDes:= Y-5;
              Vivo:= True;
              Break;
            end;
end;

end.
