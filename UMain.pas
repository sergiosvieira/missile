unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,Math, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  xO,yO,xD,yD,xP,yP: Double;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  xvel,yvel: Double;
  vel: double;
  Espaco: Double;
  i: integer;
begin
  xo:= clientwidth div 2;
  yo:= clientheight div 2;
  xp:= xo;
  yp:= yo;
  vel:= 1;

  Canvas.TextOut(Trunc(xo),Trunc(yo),'Origem');
  Canvas.TextOut(Trunc(xd),Trunc(yd),'Destino');

  Espaco:= Sqrt(Power((xd-xo),2)+Power((yd-yo),2));
  for i:= 0 to Trunc(Espaco) do
  begin
    xvel:= vel/espaco*(xd-xo);
    yvel:= vel/espaco*(yd-yo);
    Canvas.TextOut(Trunc(xp),Trunc(yp),'º');
    xp:= xp + xvel;
    yp:= yp + yvel;
  end;


end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  xd:= X;
  yd:= Y;
end;

end.
